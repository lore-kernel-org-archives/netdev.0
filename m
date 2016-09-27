From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: ISDN-Gigaset: Release memory in gigaset_initcs() after an
 allocation failure
Date: Tue, 27 Sep 2016 09:28:17 +0200
Message-ID: <a497b7aa-7719-7681-e0c1-8efeee6ce5d4@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
 <20160927071246.GT13620@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:49188 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751237AbcI0H2n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 03:28:43 -0400
In-Reply-To: <20160927071246.GT13620@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch creates new bugs.

Thanks for your information.


> I have a policy of not telling Markus where the bug is,

I find this kind of response strange.


> because otherwise he'll just resend the patch

This can also happen when the other contributors request it.


> and I have told him many times to stop sending these cleanup patches

Software "cleanups" seem to stress the review process to some degree.


> that just introduce bugs and waste maintainer time.

I guess that the situation is mixed depending on the subsystem
or concrete software module, isn't it?

Regards,
Markus
