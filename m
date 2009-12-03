From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ip: add support for IFA_F_DADFAILED
Date: Thu, 3 Dec 2009 12:10:15 -0800
Message-ID: <20091203121015.7a7c069e@nehalam>
References: <4AAEAEE7.4090507@hp.com>
	<4B1813E7.2030004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35124 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752727AbZLCUKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 15:10:34 -0500
In-Reply-To: <4B1813E7.2030004@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Dec 2009 14:39:19 -0500
Brian Haley <brian.haley@hp.com> wrote:

> Hi Stephen,
> 
> Brian Haley wrote:
> > [I'm not sure if I needed to update if_addr.h, or if that will happen
> >  automatically when you update the headers to 2.6.32]
> > 
> > 
> > Add support for IFA_F_DADFAILED and update ip.8 man page.
> 
> It looks like you applied a test patch I had sent Jens instead of this
> one.  Can you revert that and apply this instead?  Or I can send a new
> one based on your current git tree.
> 
> Thanks,

Delta would be easier.

-- 
