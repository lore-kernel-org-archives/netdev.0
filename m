From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2016-12-01
Date: Thu, 1 Dec 2016 12:48:04 +0100
Message-ID: <1480592885-3903-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50114 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751140AbcLALsM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 06:48:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just one patch this time:

1) Remove the unused make_jiffies helper.
   From Florian Westphal.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 31fbe81fe3426dfb7f8056a7f5106c6b1841a9aa:

  Merge branch 'qcom-emac-acpi' (2016-09-29 01:50:20 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 2258d927a691ddd2ab585adb17ea9f96e89d0638:

  xfrm: remove unused helper (2016-09-30 08:20:56 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      xfrm: remove unused helper

 net/xfrm/xfrm_state.c | 8 --------
 1 file changed, 8 deletions(-)
