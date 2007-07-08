From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9 support from 7.5.5
 ?)
Date: Sun, 08 Jul 2007 14:08:08 -0400
Message-ID: <46912808.4010408@garzik.org>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com> <20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arjan van de Ven <arjan@linux.intel.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41889 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753262AbXGHSIP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2007 14:08:15 -0400
In-Reply-To: <20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I think rather than having a meta-discussion, which always seems to degenerate
> into finger pointing. Let's look at the code. The problem with popular drivers
> (as I too well know) is that user's seem to find every wart.  There are lots of
> old drivers that never seem to get the same scrutiny, and if they did would
> be tarred and feathered.


"it's not as scruffy as that driver in the corner" is no way to maintain 
a kernel.

	Jeff


