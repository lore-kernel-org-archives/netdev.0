From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] ATM-iphase: Adjustments for some function implementations
Date: Sun, 6 Aug 2017 08:23:44 +0200
Message-ID: <c30df8dd-a6e9-23c1-842b-afa8696e10d4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 6 Aug 2017 08:18:28 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Adjust 11 function calls together with a variable assignment
  Delete five error messages for a failed memory allocation
  Adjust four checks for null pointers

 drivers/atm/iphase.c | 95 +++++++++++++++++++++++++++-------------------------
 1 file changed, 49 insertions(+), 46 deletions(-)

-- 
2.13.4
