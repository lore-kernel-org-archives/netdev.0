From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] NFC-digital: Adjustments for four function
 implementations
Date: Mon, 22 May 2017 14:57:42 +0200
Message-ID: <7e27a76c-de7a-22ec-cf8a-31aee2000e29@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Samuel Ortiz <sameo@linux.intel.com>,
        Thierry Escande <thierry.escande@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 14:50:05 +0200

Two update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Improve a size determination in four functions
  Delete an error message for a failed memory allocation in digital_in_send()

 net/nfc/digital_core.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

-- 
2.13.0
