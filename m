From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bpf improvements
Date: Fri, 12 Aug 2016 21:57:31 -0700 (PDT)
Message-ID: <20160812.215731.2047271938291178074.davem@davemloft.net>
References: <1470964638-1313057-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcHME5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 00:57:32 -0400
In-Reply-To: <1470964638-1313057-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 11 Aug 2016 18:17:15 -0700

> Two bpf improvements:
> 1. allow bpf helpers like bpf_map_lookup_elem() access packet data directly
>   for XDP programs
> 2. enable bpf_get_prandom_u32() for tracing programs

Series applied, thanks.
