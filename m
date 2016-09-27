From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 4/5] ISDN-Gigaset: Release memory in gigaset_initcs()
 after an allocation failure
Date: Tue, 27 Sep 2016 10:12:47 +0300
Message-ID: <20160927071246.GT13620@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44395 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752060AbcI0HOV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 03:14:21 -0400
Content-Disposition: inline
In-Reply-To: <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates new bugs.

I have a policy of not telling Markus where the bug is, because
otherwise he'll just resend the patch and I have told him many times to
stop sending these cleanup patches that just introduce bugs and waste
maintainer time.

regards,
dan carpenter
