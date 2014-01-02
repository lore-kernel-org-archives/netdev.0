From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix the use of pcpu_tstats in sit
Date: Wed, 01 Jan 2014 22:53:32 -0500 (EST)
Message-ID: <20140101.225332.926325360347824976.davem@davemloft.net>
References: <1388623776-1448-1-git-send-email-roy.qing.li@gmail.com>
	<1388634182.12212.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaABDxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:53:33 -0500
In-Reply-To: <1388634182.12212.82.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Jan 2014 19:43:02 -0800

> Thats a candidate for net and stable trees.

Queued up for -stable, thanks.
