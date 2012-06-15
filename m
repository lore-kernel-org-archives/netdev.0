From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can: 2012-06-15
Date: Fri, 15 Jun 2012 12:20:43 +0200
Message-ID: <1339755644-6686-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here is a patch intended for v3.5, targeting net/master.

Dan Carpenter found a precedence error in c_can_chip_config() function
in the c_can driver, preventing that listen only + loop back mode can be
activated.

regards,
Marc

