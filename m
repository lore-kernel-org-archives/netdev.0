From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: ndisc: remove redundant check for
 !dev->addr_len
Date: Fri, 08 Mar 2013 12:30:12 -0500 (EST)
Message-ID: <20130308.123012.2042208217690158505.davem@davemloft.net>
References: <85f9fbce9b5a6ccc4e75b05dab268076e0574abf.1362740080.git.tgraf@suug.ch>
	<513A1279.3040105@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088Ab3CHRaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:30:14 -0500
In-Reply-To: <513A1279.3040105@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 09 Mar 2013 01:31:53 +0900

> Thomas Graf wrote:
>> send_sllao is already initialized with the value of dev->addr_len
>> 
>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
 ...
>> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
