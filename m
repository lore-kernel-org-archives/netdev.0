From: Michal Ostrowski <mostrows@earthlink.net>
Subject: Re: [PATCH][BUG][SECURITY] Re: Weird problem with PPPoE on tap
	interface
Date: Sun, 04 Mar 2007 07:14:24 -0600
Message-ID: <1173014065.12398.9.camel@kdsk1.austin.ibm.com>
References: <20070228123844.GA28150@florz.florz.dyndns.org>
	 <20070302.131814.23015047.davem@davemloft.net>
	 <20070304015516.GE28150@florz.florz.dyndns.org>
	 <20070303.210843.41636777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: florz@gmx.de, netdev@vger.kernel.org, mostrows@speakeasy.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:40290 "EHLO
	igw2.watson.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbXCDNOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 08:14:35 -0500
In-Reply-To: <20070303.210843.41636777.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the late reply.... I've been on the road the past few days.

I ACK the patch.

I'll need to think about it some more, but we could probably go a step
further and eliminate the MAC address from the hash as well.


-- 
Michal Ostrowski <mostrows@earthlink.net>

On Sat, 2007-03-03 at 21:08 -0800, David Miller wrote:
> From: Florian Zumbiehl <florz@gmx.de>
> Date: Sun, 4 Mar 2007 02:55:16 +0100
> 
> > Below you find a slightly changed version of the patch
> 
> I already applied your first patch, so if you have any
> fixes to submit please provide them as relative patches
> to your original change.
> 
> Thank you.
> 


