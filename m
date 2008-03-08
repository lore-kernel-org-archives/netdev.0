From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Sat, 08 Mar 2008 14:15:06 -0800 (PST)
Message-ID: <20080308.141506.193713220.davem@davemloft.net>
References: <47D0E169.5050006@miyazawa.org>
	<20080306.231947.135681188.davem@davemloft.net>
	<47D2A6B5.101@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33228
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751141AbYCHWPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 17:15:04 -0500
In-Reply-To: <47D2A6B5.101@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazunori MIAZAWA <kazunori@miyazawa.org>
Date: Sat, 08 Mar 2008 23:46:13 +0900

> David Miller wrote:
> > I am sure there is a simple solution to this problem somewhere,
> > it is just hiding :-)
> > 
> 
> I think one solution is xfrm_state has two inner_modes
> and switch them when the family is any.
> 
> This is just an idea :-p

I can't see any immediate problem with this approach.

If you like, give it a try and we can see what it
looks like :)
