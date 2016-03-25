From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 20:25:14 -0400 (EDT)
Message-ID: <20160324.202514.1053852424051420081.davem@davemloft.net>
References: <56F42A00.7050002@iogearbox.net>
	<CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
	<1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ylavic.dev@gmail.com, netdev@vger.kernel.org, tom@herbertland.com,
	w@1wt.eu, tolga.ceylan@gmail.com, cgallek@google.com,
	josh@code406.com, aconole@bytheb.org, daniel@iogearbox.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbcCYAZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 20:25:17 -0400
In-Reply-To: <1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Mar 2016 15:49:48 -0700

> That is why EBPF has LLVM backend.
> 
> Basically you can write your "BPF" program in C, and let llvm convert it
> into EBPF.
> 
> Sure, you still can write BPF manually, as you could write HTTPS server
> in assembly.

+1
