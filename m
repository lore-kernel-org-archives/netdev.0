From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/4] atm: idt77252: Adjustments for some function
 implementations
Date: Sat, 5 Aug 2017 14:24:21 +0200
Message-ID: <df946de6-8112-2a23-ec98-ac6418ca8486@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 5 Aug 2017 14:22:33 +0200

Some update suggestions were taken into account
from static source code analysis.

Markus Elfring (4):
  Adjust four function calls together with a variable assignment
  Delete an error message for a failed memory allocation in seven functions
  Improve seven size determinations
  Adjust ten checks for null pointers

 drivers/atm/idt77252.c | 68 ++++++++++++++++++++++----------------------------
 1 file changed, 30 insertions(+), 38 deletions(-)

-- 
2.13.4

