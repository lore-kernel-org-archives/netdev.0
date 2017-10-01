From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] atm: Adjustments for adummy_init()
Date: Sun, 1 Oct 2017 21:48:08 +0200
Message-ID: <8fe2ca8a-e1f7-d492-db69-c52b66143ac6@users.sourceforge.net>
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
Date: Sun, 1 Oct 2017 21:43:21 +0200

Two update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Delete an error message for a failed memory allocation
  Improve a size determination

 drivers/atm/adummy.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

-- 
2.14.2
