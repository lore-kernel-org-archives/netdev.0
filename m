From: chunkeey@web.de
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for =?utf-8?q?fullmac=09cards?=
Date: Fri, 17 Nov 2006 20:43:27 +0100
Message-ID: <200611172043.27588.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <1163169740.2662.6.camel@localhost.localdomain> <200611170042.55404.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:13457 "EHLO
	fmmailgate02.web.de") by vger.kernel.org with ESMTP
	id S1755839AbWKQTna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 14:43:30 -0500
To: Dmitry Torokhov <dtor@insightbb.com>
In-Reply-To: <200611170042.55404.dtor@insightbb.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 17. November 2006 06:42 schrieben Sie:
> >
> > No, more that my card doesn't successfully associate at all even
> > _without_ the patch on unencrypted or WEP APs; I just can't test it,
> > since my card seems to be broken...
>
> FWIW I applied the patch to tonight pull form Linus's tree and my card
> stopped associating with my AP (WEP128, Shared key). It only associated
> with my neighbour router which is running without encryption.
can you please describe your setup? I tested WEP ("restricted") with a Netgear 
WGT624 and a normal linux AP and haven't seen any problems so far.

for debugging: 
dmesg & iwevent output would be nice...
but I'll accept a short "sniffer" extract too. ;)

(it would be really good, if you can provide a package dump form a working 
setup with the old driver too!)

Christian
