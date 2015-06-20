From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] Error message clean-ups for Renesas R-Car CAN driver
Date: Sat, 20 Jun 2015 03:49:25 +0300
Message-ID: <1593397.kKIHxKLe5s@wasted.cogentembedded.com>
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

   Here's the set of 2 patches against Marc Kleine-Budde's 'linux-can.git'
repo plus 3 fix patches just posted; they are small error message cleanups for
the Renesas R-Car CAN driver.

[1/2] rcar_can: print request_irq() error code
[2/2] rcar_can: unify error messages

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-can" in
