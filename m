From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH V8 net-next 0/6] xen-net{back, front}:
 Multiple transmit and receive queues
Date: Wed, 28 May 2014 00:10:16 +0100
Message-ID: <20140527231016.GC30121@zion.uk.xensource.com>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
 <526369072.20140514160923@eikelenboom.it>
 <20140514141347.GR6332@zion.uk.xensource.com>
 <53739757.5060905@citrix.com>
 <1296806729.20140514203719@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD0380FD1@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Andrew Bennieston <andrew.bennieston@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58116 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039AbaE0XKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 19:10:17 -0400
Content-Disposition: inline
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD0380FD1@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 03:42:47PM +0100, Paul Durrant wrote:
[...]
> > 
> > > I don't currently have a public-facing git repo for this. If you'd
> > > prefer I can send you the patches directly in a tarball, which you may
> > > be able to apply more easily than grabbing them from email threads?
> > 
> > Got the patches from the thread .. but as i expected they interfere with
> > Zoltan's v3 fix for 3.15.
> > 
> 
> I realize there will be conflict when Zoli's patch (for net) and these patches (for net-next) come together, but I don't see these in the patchworks queue at all. Did they get lost somewhere?
> 

I just check, now net-next contains Zoli's patch. I will rebase this
series myself and post it some time later (Andrew left Citrix last week
if I'm not mistaken).

Wei.

>   Paul
