From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] virtio-net: support XDP_REDIRECT
Date: Wed, 20 Sep 2017 14:28:21 -0700 (PDT)
Message-ID: <20170920.142821.2032300208230027682.davem@davemloft.net>
References: <1505814163-7315-1-git-send-email-jasowang@redhat.com>
        <1505814163-7315-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        john.fastabend@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505814163-7315-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 19 Sep 2017 17:42:43 +0800

> This patch tries to add XDP_REDIRECT for virtio-net. The changes are
> not complex as we could use exist XDP_TX helpers for most of the
> work. The rest is passing the XDP_TX to NAPI handler for implementing
> batching.
> 
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
