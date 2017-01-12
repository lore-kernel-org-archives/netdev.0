From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwt_bpf: bpf_lwt_prog_cmp() can be static
Date: Thu, 12 Jan 2017 10:05:06 -0500 (EST)
Message-ID: <20170112.100506.767009438191391171.davem@davemloft.net>
References: <20170112143928.21496-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, ast@kernel.org, daniel@iogearbox.net,
        weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50128 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdALPFz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:05:55 -0500
In-Reply-To: <20170112143928.21496-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 12 Jan 2017 14:39:28 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warning:
> 
> net/core/lwt_bpf.c:355:5: warning:
>  symbol 'bpf_lwt_prog_cmp' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
