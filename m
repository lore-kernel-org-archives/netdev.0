From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Tue, 13 Oct 2015 16:34:14 +0200
Message-ID: <20151013143414.GA5445@secunet.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com>
 <20151009071710.GJ7701@secunet.com>
 <5617F908.8060807@cumulusnetworks.com>
 <561C00B9.1020301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Hajime Tazaki <thehajime@gmail.com>, <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50690 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932419AbbJMOeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 10:34:20 -0400
Content-Disposition: inline
In-Reply-To: <561C00B9.1020301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David.

On Mon, Oct 12, 2015 at 12:49:29PM -0600, David Ahern wrote:
> On 10/9/15 11:27 AM, David Ahern wrote:
> >
> >The attached patch applied to Linus' tree works for me. Currently the
> >above change is not in his tree, so I added it to this patch. Once you
> >confirm that it works for you I'll create the delta-patch for net and
> >send out.
> 
> Steffen: Have you had a chance to try the patch? Does it solve the
> vti6 problem for you?
> 

I'm not at office this week, so not able to do a test
before monday. I let you know as soon as I tried the
patch.
