package com.walkaround.app.ui.screens

import android.content.Context
import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import com.walkaround.app.models.Rental
import com.walkaround.app.services.DisputeLetterTemplate
import com.walkaround.app.services.DisputeRecipient
import com.walkaround.app.services.PDFReportGenerator
import com.walkaround.app.ui.theme.EmeraldPrimary
import com.walkaround.app.ui.theme.PorcelainBg
import com.walkaround.app.ui.theme.TextPrimary
import com.walkaround.app.ui.theme.TextSecondary
import java.io.File

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DisputeDossierScreen(
    rental: Rental,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    var renterName by remember { mutableStateOf("Jonathan Cousins") }
    var claimNumber by remember { mutableStateOf("CLM-883192") }
    var selectedRecipient by remember { mutableStateOf(DisputeRecipient.RENTAL_AGENCY) }

    val letterText = remember(renterName, claimNumber, selectedRecipient) {
        DisputeLetterTemplate.generateLetter(
            rental = rental,
            recipient = selectedRecipient,
            renterName = renterName,
            claimNumber = claimNumber
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Dispute Dossier & Letter", fontWeight = FontWeight.Bold, fontSize = 18.sp) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = {
                        val pdf = PDFReportGenerator.generatePDF(context, rental, renterName, claimNumber)
                        sharePDF(context, pdf)
                    }) {
                        Icon(Icons.Default.Share, contentDescription = "Share PDF", tint = EmeraldPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = PorcelainBg)
            )
        },
        containerColor = PorcelainBg
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Recipient Selector
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("SELECT DISPUTE RECIPIENT", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondary)
                    Spacer(modifier = Modifier.height(8.dp))
                    DisputeRecipient.values().forEach { recipient ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)
                        ) {
                            RadioButton(
                                selected = selectedRecipient == recipient,
                                onClick = { selectedRecipient = recipient }
                            )
                            Text(recipient.title, fontSize = 13.sp, modifier = Modifier.padding(start = 6.dp))
                        }
                    }
                }
            }

            // Input Fields
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("CLAIM DETAILS", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondary)
                    OutlinedTextField(
                        value = renterName,
                        onValueChange = { renterName = it },
                        label = { Text("Your Legal Name") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    OutlinedTextField(
                        value = claimNumber,
                        onValueChange = { claimNumber = it },
                        label = { Text("Claim # or Invoice Notice #") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            // Letter Preview
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("PRE-FORMATTED REBUTTAL LETTER", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = TextSecondary)
                    Spacer(modifier = Modifier.height(10.dp))
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(Color(0xFFF8FAFC), RoundedCornerShape(8.dp))
                            .padding(12.dp)
                    ) {
                        Text(
                            text = letterText,
                            fontSize = 11.sp,
                            fontFamily = FontFamily.Monospace,
                            color = TextPrimary,
                            lineHeight = 15.sp
                        )
                    }
                }
            }

            // Export Button
            Button(
                onClick = {
                    val pdf = PDFReportGenerator.generatePDF(context, rental, renterName, claimNumber)
                    sharePDF(context, pdf)
                },
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldPrimary),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth().height(48.dp)
            ) {
                Icon(Icons.Default.Share, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("Export & Share Certified PDF Dossier", fontWeight = FontWeight.Bold)
            }
        }
    }
}

private fun sharePDF(context: Context, pdfFile: File) {
    try {
        val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", pdfFile)
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "application/pdf"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        context.startActivity(Intent.createChooser(intent, "Share Walkaround Dossier"))
    } catch (e: Exception) {
        e.printStackTrace()
    }
}
