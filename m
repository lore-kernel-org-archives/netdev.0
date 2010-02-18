From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] tun: linux socket filter support
Date: Wed, 17 Feb 2010 16:35:32 -0800 (PST)
Message-ID: <20100217.163532.215667805.davem@davemloft.net>
References: <20100214110051.GA30182@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, paul.moore@hp.com,
	David.Woodhouse@intel.com, sri@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100214110051.GA30182@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 14 Feb 2010 13:00:51 +0200

> tun module already support RX filtering, however,
> this is limited to filtering by mac address.
> For virtio host, we also need filtering by vlan.
> 
> Rather than adding this directly, it seems cleaner
> to add generic socket filter support.

Both applied to net-next-2.6, thanks!
