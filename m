From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: sk_drops handling
Date: Tue, 17 Jun 2008 21:05:45 -0700 (PDT)
Message-ID: <20080617.210545.114649814.davem@davemloft.net>
References: <48582D35.40201@cosmosbay.com>
	<48586EDB.2060809@cn.fujitsu.com>
	<4858850D.9000501@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751319AbYFREFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 00:05:44 -0400
In-Reply-To: <4858850D.9000501@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 18 Jun 2008 05:46:21 +0200

> Updated patch follows.
> 
> Thank you
> 
> [PATCH]udp: sk_drops handling
> In commits 33c732c36169d7022ad7d6eb474b0c9be43a2dc1 ([IPV4]: Add raw drops
> counter) and a92aa318b4b369091fd80433c80e62838db8bc1c ([IPV4]: Add raw drops
> counter),
> Wang Chen added raw drops counter for /proc/net/raw & /proc/net/raw6

Typo, second commit header line is "IPV6..." not "IPV4...".
I fixed this when committing your change to net-next-2.6.

Thanks.
