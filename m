From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ip: print "temporary" for IPv6 temp addresses
Date: Sat, 26 Dec 2009 11:17:59 -0800
Message-ID: <20091226111759.22a9ebe1@nehalam>
References: <4AAEAF37.7020305@hp.com>
	<4B18144E.7020907@hp.com>
	<20091203122045.2f6e7cd7@nehalam>
	<4B18203D.8070309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58484 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231AbZLZTSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 14:18:05 -0500
In-Reply-To: <4B18203D.8070309@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Dec 2009 15:31:57 -0500
Brian Haley <brian.haley@hp.com> wrote:

> Stephen Hemminger wrote:
> > On Thu, 03 Dec 2009 14:41:02 -0500
> > Brian Haley <brian.haley@hp.com> wrote:
> > 
> >> Hi Stephen,
> >>
> >> Brian Haley wrote:
> >>> IPv6 addresses that have IFA_F_SECONDARY set are actually temporary addresses,
> >>> hence the IFA_F_TEMPORARY equivalent.  Change the output in this case and
> >>> allow filtering on the word "temporary".
> >> I didn't see this in your current git tree, just pinging you about it.  This
> >> would apply on top of my dad_failed patch.
> >>
> > 
> > I'll put it as well, why did patchwork not see it?
> 
> I can only assume it was my subject line?
> 
> Let me know if I need to re-send as it was based on the other one.
> 
> -Brian

This in for 2.6.33 (next version)

-- 
