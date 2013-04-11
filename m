From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] vlan TSO support for virtio-net
Date: Thu, 11 Apr 2013 16:22:24 -0400 (EDT)
Message-ID: <20130411.162224.1462196338243001372.davem@davemloft.net>
References: <1365672742-42258-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365672742-42258-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 11 Apr 2013 17:32:20 +0800

> This series simply enable the vlan TSO support for virtio-net by just initialize
> vlan_features for virtio-net and tun which allows vlan TSO packets to be
> processed in both TX and RX path for virtio-net.
> 
> Netperf shows great improvements on stream tests:

Both applied to net-next, thanks.
