From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [PATCH 2.6.17] support for TSO over IPv6
Date: Sat, 1 Jul 2006 00:01:32 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7793A4E5@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ananda Raju" <Ananda.Raju@neterion.com>, <netdev@vger.kernel.org>,
	<jgarzik@pobox.com>, <shemminger@osdl.org>,
	"Ravinandan Arakali" <Ravinandan.Arakali@neterion.com>,
	<sivakumar.subramani@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:38375 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751893AbWGAEBs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2006 00:01:48 -0400
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id BAAEC2014AC5
	for <netdev@vger.kernel.org>; Sat,  1 Jul 2006 00:01:47 -0400 (EDT)
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Herbert!
We'll fix this.

Leonid 

> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
> Sent: Friday, June 30, 2006 8:38 PM
> To: Leonid Grossman
> Cc: Ananda Raju; netdev@vger.kernel.org; jgarzik@pobox.com; 
> shemminger@osdl.org; Ravinandan Arakali; 
> sivakumar.subramani@neterion.com; Sriram Rapuru; Michael Chan
> Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
> 
> Hi Leonid:
> 
> On Fri, Jun 30, 2006 at 04:46:56PM -0400, Leonid Grossman wrote:
> > 
> > If ECE == 1, then set it to one for all datagrams.
> > If CWR == 1, then set it to one for the first datagram, and 
> set it to 
> > zero for the rest?
> 
> Exactly.
> 
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au> 
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 

