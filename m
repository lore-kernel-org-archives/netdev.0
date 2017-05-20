From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] vhost/scsi: Adjustments for five function implementations
Date: Sat, 20 May 2017 16:30:15 +0200
Message-ID: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: kvm@vger.kernel.org, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 May 2017 16:25:04 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Improve a size determination in four functions
  Delete error messages for failed memory allocations in five functions

 drivers/vhost/scsi.c | 33 +++++++++++----------------------
 1 file changed, 11 insertions(+), 22 deletions(-)

-- 
2.13.0

