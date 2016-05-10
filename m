From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next 1/4] xen-netback: add control ring boilerplate
Date: Tue, 10 May 2016 13:46:57 +0000
Message-ID: <0f5f098b9b434e8d917a8d9114c3254c@AMSPEX02CL03.citrite.net>
References: <1462447170-1815-1-git-send-email-paul.durrant@citrix.com>
 <1462447170-1815-2-git-send-email-paul.durrant@citrix.com>
 <20160510132915.GC12241@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:51896 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbcEJNrT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 09:47:19 -0400
In-Reply-To: <20160510132915.GC12241@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 10 May 2016 14:29
> To: Paul Durrant
> Cc: xen-devel@lists.xenproject.org; netdev@vger.kernel.org; Wei Liu
> Subject: Re: [PATCH net-next 1/4] xen-netback: add control ring boilerplate
> 
> On Thu, May 05, 2016 at 12:19:27PM +0100, Paul Durrant wrote:
> [...]
> >
> > +static int connect_ctrl_ring(struct backend_info *be)
> > +{
> 
> Please use goto style error handling in this function.
> 

Will do.

> Other than this the code looks good.
> 

Thanks,

  Paul

> Wei.
