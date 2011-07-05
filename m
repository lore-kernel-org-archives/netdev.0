From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 destination cache in Linux kernel
Date: Mon, 04 Jul 2011 17:46:19 -0700 (PDT)
Message-ID: <20110704.174619.1196575558517508080.davem@davemloft.net>
References: <CF5C0F47-9A82-44CF-8441-AC23C26E476B@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mparemm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972Ab1GEAq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 20:46:26 -0400
In-Reply-To: <CF5C0F47-9A82-44CF-8441-AC23C26E476B@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikhail Paremski <mparemm@gmail.com>
Date: Mon, 4 Jul 2011 17:35:04 -0700

> 1. What are the reasons to rout datagrams differently fromIPv4?

It was just a design decision made when the ipv6 routing code
was implemented.

> 2. Where I could get details how IPv6 stack routes datagrams?

By reading the source code.
