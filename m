From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/5] ISDN-Gigaset: Use kmalloc_array() in two functions
Date: Wed, 28 Sep 2016 19:44:04 +0200
Message-ID: <1475084644.16606.44.camel@tiscali.nl>
References: <566ABCD9.1060404@users.sourceforge.net>
         <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
         <4fb300f1-ff02-7983-464f-fcbca5919dac@users.sourceforge.net>
         <1475062635.16606.27.camel@tiscali.nl>
         <1a101dea-006f-f507-54e5-5d05ccd996ec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud3.xs4all.net ([194.109.24.26]:52374 "EHLO
        lb2-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751858AbcI1RoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 13:44:10 -0400
In-Reply-To: <1a101dea-006f-f507-54e5-5d05ccd996ec@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-28 at 18:38 +0200, SF Markus Elfring wrote:
> > I'm not going to change code just because some checker suggests to
> > do so.
> 
> The script "checkpatch.pl" can point information out like the
> following.
> 
> WARNING: Prefer kmalloc_array over kmalloc with multiply

Am I being trolled?


Paul Bolle
