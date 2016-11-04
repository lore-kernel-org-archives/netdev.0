From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH v3 0/2] net: ethernet: nb8800: Do not apply TX delay at MAC
 level
Date: Fri, 4 Nov 2016 19:21:35 +0100
Message-ID: <581CD1AF.6030300@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is v3 of the series, it fixes formatting issues of v2.

In v2 of the series, only the second patch:
"net: ethernet: nb8800: handle all RGMII definitions" is modified
to account for Florian's suggestion.

Sebastian Frias (2):
  net: ethernet: nb8800: Do not apply TX delay at MAC level
  net: ethernet: nb8800: handle all RGMII definitions

 drivers/net/ethernet/aurora/nb8800.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

-- 
1.7.11.2
