From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 00/13] lwtunnel: per route ipv6 support for
 vxlan
Date: Thu, 20 Aug 2015 15:42:55 -0700 (PDT)
Message-ID: <20150820.154255.783080329849248008.davem@davemloft.net>
References: <cover.1440071726.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbbHTWm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 18:42:59 -0400
In-Reply-To: <cover.1440071726.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 20 Aug 2015 13:56:19 +0200

> v3: Moved LWTUNNEL_ENCAP_IP6 definition in patch 13.
> v2: Fixed issues in patch 4 pointed out by Alexei.
> 
> This series enables IPv6 tunnels based on lwtunnel infrastructure. Only
> vxlan is supported for now.
> 
> Tested in all combinations of IPv4 over IPv6, IPv6 over IPv4 and IPv6 over
> IPv6.

Looks good, series applied, thanks!
