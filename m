From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: fix leaking of ctx array
Date: Fri, 07 Jul 2017 20:04:24 +0100 (WEST)
Message-ID: <20170707.200424.1596171605830720958.davem@davemloft.net>
References: <1499428569-1608-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499428569-1608-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri,  7 Jul 2017 19:56:09 +0800

> Fixes: commit d45b897b11ea ("virtio_net: allow specifying context for rx")
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks Jason.
