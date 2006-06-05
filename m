From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: OLPC (One Laptop Per Child) Developer's program.
Date: Mon, 05 Jun 2006 10:07:33 +0100
Message-ID: <1149498453.30024.48.camel@pmac.infradead.org>
References: <1149025377.30703.141.camel@localhost.localdomain>
	 <1149335345.5053.177.camel@pmac.infradead.org> <e5umgs$lfj$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([205.233.218.70]:50866 "EHLO
	canuck.infradead.org") by vger.kernel.org with ESMTP
	id S1750814AbWFEJHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 05:07:42 -0400
To: Anand Kumria <wildfire@progsoc.org>
In-Reply-To: <e5umgs$lfj$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-06-04 at 13:17 +0000, Anand Kumria wrote:
> > One thing we really need is NAT-PT or an equivalent for allowing access
> > to the Legacy Internet from IPv6-only hosts. As soon as I finish playing
> > with JFFS2 improvements, I plan to start looking at that.
> 
> Wouldn't miredo mostly fit the bill? It won't get through Symmetric NATs
> (by design) but those are supposed to be uncommon. 

That seems to be a method for IPv4 hosts to get IPv6 connectivity. What
I'm after is a method for IPv6 hosts to get IPv4 connectivity -- like
NAT-PT.

-- 
dwmw2

