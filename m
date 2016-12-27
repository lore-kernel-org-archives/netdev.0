From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net: xdp: remove unused bfp_warn_invalid_xdp_buffer()
Date: Tue, 27 Dec 2016 10:29:28 +0100
Message-ID: <58623478.10803@iogearbox.net>
References: <1482806994-14649-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>
To: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57269 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbcL0J3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 04:29:33 -0500
In-Reply-To: <1482806994-14649-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2016 03:49 AM, Jason Wang wrote:
> After commit 73b62bd085f4737679ea9afc7867fa5f99ba7d1b ("virtio-net:
> remove the warning before XDP linearizing"), there's no users for
> bpf_warn_invalid_xdp_buffer(), so remove it. This is a revert for
> commit f23bc46c30ca5ef58b8549434899fcbac41b2cfc.
>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Thanks for following up.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
