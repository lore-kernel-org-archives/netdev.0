From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 68] drivers/net/s2io.c: kmalloc + memset conversion to k[cz]alloc
Date: Wed, 8 Aug 2007 12:16:36 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77020354C0@nekter>
References: <46B8EAD0.2040303@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: "Jeff Garzik" <jgarzik@pobox.com>,
	"Mariusz Kozlowski" <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:28003 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304AbXHHQUL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 12:20:11 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46B8EAD0.2040303@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have a few patches queued and can send this patch in along with ours.

Ram

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Jeff Garzik
> Sent: Tuesday, August 07, 2007 2:58 PM
> To: Mariusz Kozlowski
> Cc: linux-kernel@vger.kernel.org; kernel-janitors@vger.kernel.org;
Andrew
> Morton; netdev@vger.kernel.org
> Subject: Re: [PATCH 68] drivers/net/s2io.c: kmalloc + memset
conversion to
> k[cz]alloc
> 
> Mariusz Kozlowski wrote:
> > Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> >
> >  drivers/net/s2io.c | 235587 -> 235340 (-247 bytes)
> >  drivers/net/s2io.o | 460768 -> 460120 (-648 bytes)
> >
> >  drivers/net/s2io.c |   14 +++++---------
> >  1 file changed, 5 insertions(+), 9 deletions(-)
> 
> ACK but didn't apply, please wait 24-48 hours (so that s2io fixes go
> upstream), then rediff and resend
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
