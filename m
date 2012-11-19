From: wfp5p@viridian.itc.virginia.edu (Bill Pemberton)
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 19 Nov 2012 16:30:09 -0500
Message-ID: <20121119213009.D5AC680204@viridian.itc.virginia.edu>
References: <alpine.LNX.2.01.1211192222160.12904@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org (Greg KH),
	macro@linux-mips.org (Maciej W. Rozycki), netdev@vger.kernel.org
To: jengelh@inai.de (Jan Engelhardt)
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:43268 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816Ab2KSVaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 16:30:10 -0500
In-Reply-To: <alpine.LNX.2.01.1211192222160.12904@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt writes:
> 
> On Monday 2012-11-19 20:29, Greg KH wrote:
> >
> >CONFIG_HOTPLUG is always enabled now, so that's not an option anymore.
> >And again, a user can "hot unbind" a driver from a device from
> >userspace, no matter if the bus physically supports it or not.
> 
> Which mailing list was this originally posted on? (I only have 
> subscribed to netdev, and google has not indexed 000/493--001/493 yet.)
> 

The announcement for this patchset was sent to lkml on Friday.  I
originally didn't have the patches themselves Cc'd to the various
subsystems, so no one other than Greg got the patches themselves on
Friday.  I resent them with Cc's today.

-- 
Bill
