From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: call notifiers for mtu change even if
 iface is not up
Date: Fri, 07 Dec 2012 12:23:12 -0500 (EST)
Message-ID: <20121207.122312.1478218763883956086.davem@davemloft.net>
References: <20121203152250.GB21816@hmsreliant.think-freely.org>
	<20121207122920.GB1631@minipsycho.zyxel.com>
	<20121207150708.GA29819@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com, psimerda@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423001Ab2LGRXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:23:14 -0500
In-Reply-To: <20121207150708.GA29819@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 7 Dec 2012 10:07:08 -0500

> On Fri, Dec 07, 2012 at 01:29:20PM +0100, Jiri Pirko wrote:
>> Mon, Dec 03, 2012 at 04:22:50PM CET, nhorman@tuxdriver.com wrote:
>> >On Mon, Dec 03, 2012 at 03:22:29PM +0100, Jiri Pirko wrote:
>> >> Mon, Dec 03, 2012 at 03:18:23PM CET, nhorman@tuxdriver.com wrote:
>> >> >On Mon, Dec 03, 2012 at 12:16:32PM +0100, Jiri Pirko wrote:
>> >> >> Do the same thing as in set mac. Call notifiers every time.
>> >> >> 
>> >> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
 ...
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
