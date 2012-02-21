From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 21:41:23 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F95DC9@ORSMSX106.amr.corp.intel.com>
References: <20120221.161630.1122203779408129070.davem@davemloft.net>
	<20120221.162125.1533105883101299190.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F95D79@ORSMSX106.amr.corp.intel.com>
 <20120221.163209.2238982548619784853.davem@davemloft.net>
 <C5551D9AAB213A418B7FD5E4A6F30A0702F95DAC@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6552 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755640Ab2BUVlY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:41:24 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F95DAC@ORSMSX106.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Rose, Gregory V
> Sent: Tuesday, February 21, 2012 1:34 PM
> To: David Miller
> Cc: netdev@vger.kernel.org
> Subject: RE: [PATCH] rtnetlink: Fix problem with buffer allocation
> 
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Tuesday, February 21, 2012 1:32 PM
> > To: Rose, Gregory V
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [PATCH] rtnetlink: Fix problem with buffer allocation
> >
> > From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> > Date: Tue, 21 Feb 2012 21:28:17 +0000
> >
> > > I compile tested it on my development machine and then exported it
> > > to a machine that can connect to the internet and mail patches.  I
> > > must have screwed something up at that point.
> > >
> > > Let me see what the heck I did.
> >
> > It looks like a quarter of the patch got lost, because if you look at
> > the RFC,V3 version of your patch at:
> >
> > http://patchwork.ozlabs.org/patch/141714/
> >
> > all the necessary bits appear to be there.
> 
> Yeah, I screwed the pooch somewhere between making the last update you
> requested and then pushing the patch.  I have no idea what I did but I'll
> fix it up and repost.

I sent from the wrong branch.  I'd been in the process of moving the patch over to another development branch on my git tree and it wasn't up to date.

The correct patch from the right dev branch will be up in a couple of minutes.

- Greg
