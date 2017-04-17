From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bpf: LRU performance and test-program
 improvements
Date: Mon, 17 Apr 2017 13:56:11 -0400 (EDT)
Message-ID: <20170417.135611.839820747634220150.davem@davemloft.net>
References: <20170414173030.2853860-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56160 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752904AbdDQR4P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:56:15 -0400
In-Reply-To: <20170414173030.2853860-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 14 Apr 2017 10:30:24 -0700

> The first 4 patches make a few improvements to the LRU tests.
> 
> Patch 5/6 is to improve the performance of BPF_F_NO_COMMON_LRU map.
> 
> Patch 6/6 adds an example in using LRU map with map-in-map.

Series applied, thank you.
