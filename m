From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 0/2] virtio_net: fix race in RX VQ processing
Date: Tue, 9 Jul 2013 13:21:02 +0300
Message-ID: <20130709102102.GA14321@redhat.com>
References: <1373346713-442-1-git-send-email-mst@redhat.com>
 <20130709.023222.767482110746812707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130709.023222.767482110746812707.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 09, 2013 at 02:32:22AM -0700, David Miller wrote:
> 
> I don't see patch #1 in v2 of this series.

It's there now:
http://patchwork.ozlabs.org/patch/257692/
