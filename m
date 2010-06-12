From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: hamachi on offer
Date: Sat, 12 Jun 2010 13:30:19 -0400
Message-ID: <20100612173019.GG10049@kvack.org>
References: <20100612095125.GA16967@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:57028 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750725Ab0FLRwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jun 2010 13:52:42 -0400
Content-Disposition: inline
In-Reply-To: <20100612095125.GA16967@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andi,

On Sat, Jun 12, 2010 at 11:51:25AM +0200, Andi Kleen wrote:
> Hi,
> 
> I found an old hamachi (Packet Engines GNIC II) PCI GigE card while
> going through old junk. 
..
> Please only serious offers if you want to actually work with the code.

I have a fibre NatSemi DP83820 gige that should interoperate with this, and 
which needs testing as well.  I'd be willing to update and test the two 
drivers to the point of getting them working.  I also have access to media 
convertors, plus a few reasons to set up an automated test suite (more to 
test the media convertors, but testing the nics would be a beneficial side 
effect).  If someone else wants to maintain this longer term, I'd be 
willing to pass along the other fibre nic and some media convertors to 
help out.

		-ben
