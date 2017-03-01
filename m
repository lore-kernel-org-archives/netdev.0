From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: update the comment about the length of analysis
Date: Wed, 01 Mar 2017 15:03:01 -0800 (PST)
Message-ID: <20170301.150301.1283790044107215608.davem@davemloft.net>
References: <20170301082551.7388-1-glin@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ast@kernel.org, daniel@iogearbox.net
To: glin@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752845AbdCAXLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 18:11:36 -0500
In-Reply-To: <20170301082551.7388-1-glin@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gary Lin <glin@suse.com>
Date: Wed,  1 Mar 2017 16:25:51 +0800

> Commit 07016151a446 ("bpf, verifier: further improve search
> pruning") increased the limit of processed instructions from
> 32k to 64k, but the comment still mentioned the 32k limit.
> This commit updates the comment to reflect the change.
> 
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Gary Lin <glin@suse.com>

Applied, thanks.
