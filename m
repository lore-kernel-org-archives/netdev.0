From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] usbnet: Adjustments for usbnet_write_cmd_async()
Date: Mon, 22 May 2017 07:07:49 +0200
Message-ID: <a81c2551-ce6c-967d-1120-4307f95b1e65@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 07:04:03 +0200

Two update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Delete an error message for a failed memory allocation
  Improve a size determination

 drivers/net/usb/usbnet.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

-- 
2.13.0
