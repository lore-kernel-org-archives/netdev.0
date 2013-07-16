From: Matt Wilson <msw@amazon.com>
Subject: Re: [Xen-devel] [PATCH RFC] xen-netback: calculate the number of
 slots required for large MTU vifs
Date: Tue, 16 Jul 2013 10:40:55 -0700
Message-ID: <20130716174055.GA4401@u109add4315675089e695.ant.amazon.com>
References: <20130709221406.GA13671@u109add4315675089e695.ant.amazon.com>
 <1373409659-22383-1-git-send-email-msw@amazon.com>
 <20130710081333.GI19798@zion.uk.xensource.com>
 <20130710193703.GB20453@zion.uk.xensource.com>
 <20130711051441.GA5189@u109add4315675089e695.ant.amazon.com>
 <51E51B83.7040302@oracle.com>
 <20130716102719.GD5674@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: annie li <annie.li@oracle.com>, <netdev@vger.kernel.org>,
	Xi Xiong <xixiong@amazon.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:12791 "EHLO
	smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933059Ab3GPRlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 13:41:21 -0400
Content-Disposition: inline
In-Reply-To: <20130716102719.GD5674@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 16, 2013 at 11:27:19AM +0100, Wei Liu wrote:
> On Tue, Jul 16, 2013 at 06:08:03PM +0800, annie li wrote:
> > 
> > On 2013-7-11 13:14, Matt Wilson wrote:
> > >I think that this patch addresses the problem more completely. Annie?
> > 
> > Agree, it is better to take your patch. Would you like to go forward
> > with it? This issue is obvious and easy to be hit with larger MTU
> > size.
> > 
> 
> I'm going to be on vacation tomorrow. Matt, feel free to add my Acked-by to
> your patch.

Thanks, Wei. I'm on vacation now and I'll return to the office
tomorrow. Please accept my apologies for the delay.

I should have time to clean up a few things with this patch (no
functional changes) and post a final version this week.

--msw

> Wei.
> 
> > Thanks
> > Annie
