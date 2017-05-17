From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] selftests/bpf: fix broken build due to types.h
Date: Wed, 17 May 2017 19:18:46 -0400 (EDT)
Message-ID: <20170517.191846.66453906903459400.davem@davemloft.net>
References: <591CD540.1040305@iogearbox.net>
        <20170517.190149.1446382466519323776.davem@davemloft.net>
        <591CD99F.1060807@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhs@fb.com, ast@fb.com, netdev@vger.kernel.org, kernel-team@fb.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37766 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753717AbdEQXSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 19:18:49 -0400
In-Reply-To: <591CD99F.1060807@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 18 May 2017 01:15:43 +0200

> Btw, 0day kernel testing bot is from now on running BPF selftests
> as well as part of their regression tests. Fengguang confirmed this
> today after integrating this.

That's great news.
