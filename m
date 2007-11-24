From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24 2/2]S2io: Fix to aggregate vlan tagged packets
Date: Sat, 24 Nov 2007 13:12:41 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702952494@nekter>
References: <474794DC.9000606@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:17936 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbXKXSNa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 13:13:30 -0500
Content-class: urn:content-classes:message
In-Reply-To: <474794DC.9000606@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Does this patch still fail?

Ram

> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org]
> Sent: Friday, November 23, 2007 7:05 PM
> To: ram.vepa@neterion.com
> Cc: netdev@vger.kernel.org; support
> Subject: Re: [PATCH 2.6.24 2/2]S2io: Fix to aggregate vlan tagged
packets
> 
> Ramkrishna Vepa wrote:
> > - Fix to aggregate vlan packets. IP offset is incremented by
> >   4 bytes if the packet contains vlan header.
> >
> > Signed-off-by: Santoshkumar Rastapur <santosh.rastapur@neterion.com>
> > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> > ---
> 
> ACK but cannot apply due to dropped patches
> 

