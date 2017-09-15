From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf/verifier: reject BPF_ALU64|BPF_END
Date: Fri, 15 Sep 2017 15:02:00 -0700 (PDT)
Message-ID: <20170915.150200.294158435331592497.davem@davemloft.net>
References: <8c3d5513-6171-3e68-56df-1efd0e87f071@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58124 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdIOWCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 18:02:01 -0400
In-Reply-To: <8c3d5513-6171-3e68-56df-1efd0e87f071@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 15 Sep 2017 14:37:38 +0100

> Neither ___bpf_prog_run nor the JITs accept it.
> Also adds a new test case.
> 
> Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied and queued up for -stable.
