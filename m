From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore ethernet addresses
Date: Wed, 14 Nov 2007 11:47:34 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770289B951@nekter>
References: <20071114.014324.78802691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"support" <support@neterion.com>
To: "David Miller" <davem@davemloft.net>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:3246 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760135AbXKNQrh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 11:47:37 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071114.014324.78802691.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scheduling for the 2.6.25 merge window is fine. Curious - why did you
have to remove the driver version? We use it to keep track of our
changes submitted.

Thanks,
Ram

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, November 14, 2007 1:43 AM
> To: Sreenivasa Honnur
> Cc: netdev@vger.kernel.org; jeff@garzik.org; support
> Subject: Re: [PATCH 2.6.24 1/1]S2io: Support for
add/delete/store/restore
> ethernet addresses
> 
> From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
> Date: Wed, 14 Nov 2007 04:30:34 -0500 (EST)
> 
> > - Support to add/delete/store/restore 64 and 128 Ethernet addresses
for
> Xframe I and Xframe II respectively.
> >
> > - (Resubmit third time)
> >
> > Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> 
> No, this is a feature patch, so I'm not going to queue this
> up for 2.6.24, that is not appropriate at all.
> 
> Instead I've added this patch to netdev-2.6 which will
> schedule it for the 2.6.25 merge window.
> 
> I had to remove the DRV_VERSION part of your changes as
> a result.
> 
> Thanks.
