From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-08-09
Date: Fri,  9 Aug 2013 11:44:05 +0200
Message-ID: <1376041446-24058-1-git-send-email-mkl@pengutronix.de>
Cc: kernel@pengutronix.de, linux-can@vger.kernel.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

here is a fix for the v3.11 release cycle:

Stephane Grosjean has found and fixed a potential wrong length for the mempy()
in pcan_usb's decode usb data function.

regards,
Marc

