From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/3] Small fixes for Renesas R-Car CAN driver
Date: Sat, 20 Jun 2015 03:30:51 +0300
Message-ID: <2010452.WyFito6egU@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

   Here's the set of 3 patches against Marc Kleine-Budde's 'linux-can.git'
repo; they are small fixes for the Renesas R-Car CAN driver.

rcar_can: fix IRQ check
rcar_can: print signed IRQ #
rcar_can: fix typo in error message

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
