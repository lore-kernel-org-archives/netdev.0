From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 4/5] ISDN-Gigaset: Release memory in gigaset_initcs()
 after an allocation failure
Date: Tue, 27 Sep 2016 10:30:56 +0300
Message-ID: <20160927073056.GW13620@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <6409b3b0-3b7a-1139-f040-7b1a61611187@users.sourceforge.net>
 <1474924434.8546.29.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474924434.8546.29.camel@tiscali.nl>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ah well...  Someone else discovered the double free bug first and gave
it away.  Reassuring, I guess.

regards,
dan carpenter

