From: Jason Wang <jasowang@redhat.com>
Subject: Re: XDP offload to hypervisor
Date: Wed, 25 Jan 2017 11:03:46 +0800
Message-ID: <286d054e-70bf-e0ca-8db6-f2f3ec12d963@redhat.com>
References: <20170123230727-mutt-send-email-mst@kernel.org>
 <20170124010201.GB60699@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45310 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751150AbdAYDDx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 22:03:53 -0500
In-Reply-To: <20170124010201.GB60699@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月24日 09:02, Alexei Starovoitov wrote:
> Frankly I don't understand the whole virtio nit picking that was happening.
> imo virtio+xdp by itself is only useful for debugging, development and testing
> of xdp programs in a VM. The discussion about performance of virtio+xdp
> will only be meaningful when corresponding host part is done.

Maybe not, consider you may have dpdk backend on host.

Thanks
