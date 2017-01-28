From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/4] DCB netlink: Fine-tuning for some function
 implementations
Date: Sat, 28 Jan 2017 10:32:31 +0100
Message-ID: <ab981a3f-e73e-9bef-09c5-9c6d077aef00@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Pan Bian <bianpan2016@163.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Jan 2017 10:28:19 +0100

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (4):
  Use kmalloc_array() in dcbnl_build_peer_app()
  Adjust four function calls together with a variable assignment
  Adjust five checks for null pointers
  Add some spaces for better code readability

 net/dcb/dcbnl.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

-- 
2.11.0

