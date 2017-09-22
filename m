From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH net-next RFC 3/5] vhost: introduce vhost_add_used_idx()
Date: Fri, 22 Sep 2017 10:07:30 +0100
Message-ID: <20170922090730.GC9243@stefanha-x1.localdomain>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kvm@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506067355-5771-4-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2017 at 04:02:33PM +0800, Jason Wang wrote:
> This patch introduces a helper which just increase the used idx. This
> will be used in pair with vhost_prefetch_desc_indices() by batching
> code.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/vhost.c | 33 +++++++++++++++++++++++++++++++++
>  drivers/vhost/vhost.h |  1 +
>  2 files changed, 34 insertions(+)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
