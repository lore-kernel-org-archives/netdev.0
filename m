From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] hostap: Fine-tuning for a few functions
Date: Sat, 20 Aug 2016 18:43:16 +0200
Message-ID: <f0cd7a82-e603-6a91-0afd-33bbd1658cab@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 Aug 2016 18:35:43 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Use memdup_user()
  Delete an unnecessary jump label
  Delete unnecessary variable initialisations

 .../net/wireless/intersil/hostap/hostap_ioctl.c    | 36 ++++++++--------------
 1 file changed, 12 insertions(+), 24 deletions(-)

-- 
2.9.3

