From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] inet: tcp listener refactoring, part 10
Date: Mon, 16 Mar 2015 15:56:10 -0400 (EDT)
Message-ID: <20150316.155610.978122823818191251.davem@davemloft.net>
References: <1426479136-15645-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755463AbbCPT4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 15:56:12 -0400
In-Reply-To: <1426479136-15645-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun, 15 Mar 2015 21:12:11 -0700

> We are getting close to the point where request sockets will be hashed
> into generic hash table. Some followups are needed for netfilter and
> will be handled in next patch series.

Looks great, series applied, thanks!
