From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] net-iwlegacy: Fine-tuning for il_eeprom_init()
Date: Fri, 1 Jan 2016 21:27:43 +0100
Message-ID: <5686E13F.2010309@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>,
	Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 1 Jan 2016 21:25:43 +0100

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Refactoring
  One check less after error detection
  Another refactoring

 drivers/net/wireless/intel/iwlegacy/common.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

-- 
2.6.3
