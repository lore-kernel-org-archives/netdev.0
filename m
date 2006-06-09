From: Mark Lord <lkml@rtr.ca>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Fri, 09 Jun 2006 11:24:39 -0400
Message-ID: <448992B7.1050906@rtr.ca>
References: <44886381.9050506@goop.org> <200606090546.15923.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([64.26.128.89]:5043 "EHLO mail.rtr.ca")
	by vger.kernel.org with ESMTP id S1030427AbWFITYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 15:24:41 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200606090546.15923.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> 
> If your laptop has firewire you can also use firescope.
> (ftp://ftp.suse.com/pub/people/ak/firescope/) 
..
> FW keeps running as long as nobody resets the ieee1394 chip.

This looks interesting.  But how does one set it up for use
on the *other* end of that firewire cable?  The Quickstart and
manpage don't seem to describe this fully.

Thanks
