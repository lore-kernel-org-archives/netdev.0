From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] net/atm: Fine-tuning for three function implementations
Date: Tue, 2 May 2017 19:45:31 +0200
Message-ID: <d9577c1f-07d1-b43a-df16-8626acfb1043@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 2 May 2017 19:37:39 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Combine four seq_printf() calls in mpc_show()
  Use seq_putc() in mpc_show()
  Add some spaces for better code readability

 net/atm/mpoa_proc.c | 37 ++++++++++++++++++++-----------------
 1 file changed, 20 insertions(+), 17 deletions(-)

-- 
2.12.2
