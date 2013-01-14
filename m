From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter fixes for 3.8-rc3
Date: Mon, 14 Jan 2013 18:27:29 -0500 (EST)
Message-ID: <20130114.182729.2180886298032512388.davem@davemloft.net>
References: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756959Ab3ANX1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 18:27:31 -0500
In-Reply-To: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Tue, 15 Jan 2013 00:24:02 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Hi David,
> 
> The following patchset contains netfilter fixes for 3.8-rc3,
> they are:
> 
> * fix possible BUG_ON if several netns are in use and the nf_conntrack
>   module is removed, initial patch from Gao feng, final patch from myself.
> 
> * fix unset return value if conntrack zone are disabled at
>   compile-time, reported by Borislav Petkov, fix from myself.
> 
> * fix display error message via dmesg for arp_tables, from Jan Engelhardt.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks Pablo.
