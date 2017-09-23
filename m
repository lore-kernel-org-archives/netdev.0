From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: correctly set xdp_xmit for
 mergeable buffer
Date: Fri, 22 Sep 2017 18:16:21 -0700 (PDT)
Message-ID: <20170922.181621.639395877867842082.davem@davemloft.net>
References: <1506062338-3617-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        john.fastabend@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506062338-3617-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 22 Sep 2017 14:38:58 +0800

> We should set xdp_xmit only when xdp_do_redirect() succeed.
> 
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
