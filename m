From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 04 Apr 2014 09:54:20 -0400 (EDT)
Message-ID: <20140404.095420.1460518706334112992.davem@davemloft.net>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, vfalico@redhat.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hkchu@google.com, dborkman@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, atzm@stratosphere.co.jp, phil@nwl.cc,
	richardcochran@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbaDDNwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 09:52:49 -0400
In-Reply-To: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  4 Apr 2014 14:20:38 +0200

> The priv is used now by af_packet. Rename it to make it useable for
> others as well. Also, introduce packet_id_match to move the sk matching
> from skb_loop_sk to af_packet code where it belongs.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Firstly, net-next is closed.

Secondly, submit this with the unmentioned and mysterious "other
user", there currently are none.
