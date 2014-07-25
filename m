From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] [linux-next] netfilter: kill remnants of ulog targets
Date: Fri, 25 Jul 2014 15:01:34 +0200
Message-ID: <20140725130134.GC13940@salvia>
References: <1406107694.12441.8.camel@x220>
 <20140723093949.GA3754@salvia>
 <1406291131.8231.20.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58784 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760237AbaGYNBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 09:01:23 -0400
Content-Disposition: inline
In-Reply-To: <1406291131.8231.20.camel@x220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2014 at 02:25:31PM +0200, Paul Bolle wrote:
> The ulog targets were recently killed. A few references to the Kconfig
> macros CONFIG_IP_NF_TARGET_ULOG and CONFIG_BRIDGE_EBT_ULOG were left
> untouched. Kill these too.

Those were my fault, applied, thanks Paul.
