From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/12] Implement XDP bpf_redirect
Date: Mon, 17 Jul 2017 09:48:26 -0700 (PDT)
Message-ID: <20170717.094826.767162378044837983.davem@davemloft.net>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        brouer@redhat.com, andy@greyhouse.net
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751301AbdGQQs1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:48:27 -0400
In-Reply-To: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 17 Jul 2017 09:26:02 -0700

> This series adds two new XDP helper routines bpf_redirect() and
> bpf_redirect_map(). The first variant bpf_redirect() is meant
> to be used the same way it is currently being used by the cls_bpf
> classifier. An xdp packet will be redirected immediately when this
> is called.

Awesome, series applied, thanks!
