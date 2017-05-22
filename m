From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/2] ieee802154: ca8210: Adjustments for two function
 implementations
Date: Mon, 22 May 2017 10:28:02 +0200
Message-ID: <9247C8F0-7FA1-4D02-96D5-DFB9753D7C05@holtmann.org>
References: <55fddbc7-28c4-8866-67d3-ff1ff1a4eeb7@users.sourceforge.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxdev@cascoda.com, linux-wpan@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Alexander Aring <aar@pengutronix.de>,
        Harry Morris <h.morris@cascoda.com>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:33662 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752994AbdEVI2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 04:28:04 -0400
In-Reply-To: <55fddbc7-28c4-8866-67d3-ff1ff1a4eeb7@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Markus,

> Two update suggestions were taken into account
> from static source code analysis.
> 
> Markus Elfring (2):
>  Delete an error message for a failed memory allocation in ca8210_probe()
>  Delete an error message for a failed memory allocation in ca8210_skb_rx()
> 
> drivers/net/ieee802154/ca8210.c | 9 ++-------
> 1 file changed, 2 insertions(+), 7 deletions(-)

both patches have been applied to bluetooth-next tree.

Regards

Marcel
