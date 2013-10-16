From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v4 0/5] xen-netback: IPv6 offload
 support
Date: Wed, 16 Oct 2013 18:00:38 +0100
Message-ID: <1381942838.30409.26.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381940401.30409.9.camel@kazak.uk.xensource.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD013B267@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:40575 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760805Ab3JPRAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 13:00:43 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD013B267@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 17:53 +0100, Paul Durrant wrote:
> > -----Original Message-----
> > From: Ian Campbell
> > Sent: 16 October 2013 17:20
> > To: Paul Durrant
> > Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org
> > Subject: Re: [Xen-devel] [PATCH net-next v4 0/5] xen-netback: IPv6 offload
> > support
> > 
> > On Fri, 2013-10-11 at 16:06 +0100, Paul Durrant wrote:
> > > This patch series adds support for checksum and large packet offloads into
> > > xen-netback.
> > > Testing has mainly been done using the Microsoft network hardware
> > > certification suite running in Server 2008R2 VMs with Citrix PV frontends.
> > 
> > Are there any Linux netfront patches in existence/the pipeline to take
> > advantage of this?
> > 
> 
> I was waiting for the backend patches to be accepted first ;-)

I think it would be useful to get et least an RFC so others can try it
etc.

Ian.
