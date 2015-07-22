From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: don't require ANY_LAYOUT with VERSION_1
Date: Wed, 22 Jul 2015 13:08:06 +0300
Message-ID: <20150722130735-mutt-send-email-mst@redhat.com>
References: <1436963135-16592-1-git-send-email-mst@redhat.com>
 <20150720.124259.1513329118631759070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	jasowang@redhat.com, virtio-dev@lists.oasis-open.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150720.124259.1513329118631759070.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 20, 2015 at 12:42:59PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 15 Jul 2015 15:26:19 +0300
> 
> > ANY_LAYOUT is a compatibility feature. It's implied
> > for VERSION_1 devices, and non-transitional devices
> > might not offer it. Change code to behave accordingly.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Applied.

Thanks!
Please also forward this to stable as it's a spec
compliance question.

-- 
MST
