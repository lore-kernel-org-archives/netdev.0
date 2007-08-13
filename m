From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24]S2io: Default to IntA interrupt type when there are less than 4 CPUs in the system.
Date: Mon, 13 Aug 2007 01:59:39 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702035C84@nekter>
References: <p73sl6oishx.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jeff@garzik.org>, "Rick Jones" <rick.jones2@hp.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	<netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:31492 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754712AbXHMF7m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 01:59:42 -0400
Content-class: urn:content-classes:message
In-Reply-To: <p73sl6oishx.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We will be releasing it to the mainline soon. The patches are getting
queued at our end for test and release. It should be out in a couple of
weeks.

Ram
> -----Original Message-----
> From: ak@suse.de [mailto:ak@suse.de] On Behalf Of Andi Kleen
> Sent: Sunday, August 12, 2007 10:16 AM
> To: Ramkrishna Vepa
> Cc: Jeff Garzik; Rick Jones; Sivakumar Subramani;
netdev@vger.kernel.org;
> support
> Subject: Re: [PATCH 2.6.24]S2io: Default to IntA interrupt type when
there
> are less than 4 CPUs in the system.
> 
> "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com> writes:
> 
> > In one of the variations of this driver that is not
> > released to netdev, the received packets are steered to a channel
based
> > on hashing on a preconfigured criteria such as sockets on tcp_ipv4,
> > udp_ipv4, tcp_ipv6, udp_ipv6 or addresses in ipv4/6.
> 
> Why is it not released for mainline? It sounds interesting.
> 
> -Andi

