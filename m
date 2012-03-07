From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Wed, 07 Mar 2012 06:25:25 -0800
Message-ID: <4F576FD5.2050208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-netdev <netdev@vger.kernel.org>,
	Linux-wireless <linux-wireless@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ath9k craps out from time to time(more annoying if anything)

[44309.840830] ath: Failed to stop TX DMA, queues=0x001!
[44309.858246] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
[44309.858255] ath: Could not stop RX, we could be confusing the DMA 
engine when we start RX up
[44309.932801] ath: Failed to stop TX DMA, queues=0x001!
[44309.950352] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
[44309.950361] ath: Could not stop RX, we could be confusing the DMA 
engine when we start RX up
[44310.024301] ath: Failed to stop TX DMA, queues=0x001!
[44310.041641] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
[44310.041646] ath: Could not stop RX, we could be confusing the DMA 
engine when we start RX up
[44310.116316] ath: Failed to stop TX DMA, queues=0x001!
[44310.133909] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
[44310.133918] ath: Could not stop RX, we could be confusing the DMA 
engine when we start RX up
[44310.208021] ath: Failed to stop TX DMA, queues=0x001!
[44310.225752] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
[44310.225761] ath: Could not stop RX, we could be confusing the DMA 
engine when we start RX up
[44310.299922] ath: Failed to stop TX DMA, queues=0x001!
[44310.317579] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
[44310.317587] ath: Could not stop RX, we could be confusing the DMA 
engine whe


part of dmesg here:
http://fpaste.org/xew6/
I can supply full log if needed..

Justin P. Mattock
