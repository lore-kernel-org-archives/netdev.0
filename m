From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: xdp: remove unused
 bfp_warn_invalid_xdp_buffer()
Date: Tue, 27 Dec 2016 12:30:03 -0500 (EST)
Message-ID: <20161227.123003.1918493504680256362.davem@davemloft.net>
References: <1482806994-14649-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, john.r.fastabend@intel.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40628 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755917AbcL0RaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 12:30:05 -0500
In-Reply-To: <1482806994-14649-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 27 Dec 2016 10:49:54 +0800

> After commit 73b62bd085f4737679ea9afc7867fa5f99ba7d1b ("virtio-net:
> remove the warning before XDP linearizing"), there's no users for
> bpf_warn_invalid_xdp_buffer(), so remove it. This is a revert for
> commit f23bc46c30ca5ef58b8549434899fcbac41b2cfc.
> 
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
