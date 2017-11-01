From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix verifier memory leaks
Date: Wed, 01 Nov 2017 22:07:47 +0900 (KST)
Message-ID: <20171101.220747.1821485497784610167.davem@davemloft.net>
References: <20171101070804.1848191-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ecree@solarflare.com,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdKANHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 09:07:55 -0400
In-Reply-To: <20171101070804.1848191-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 1 Nov 2017 00:08:04 -0700

> fix verifier memory leaks
> 
> Fixes: 638f5b90d460 ("bpf: reduce verifier memory consumption")
> Signed-off-by: Alexei Starovoitov <ast@fb.com>

Applied.
