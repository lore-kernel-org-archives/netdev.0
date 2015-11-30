From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] vhost: replace % with & on data path
Date: Mon, 30 Nov 2015 11:17:51 -0500 (EST)
Message-ID: <20151130.111751.1895197869749676169.davem@redhat.com>
References: <1448874894-18398-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448874894-18398-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 30 Nov 2015 11:15:23 +0200

> We know vring num is a power of 2, so use &
> to mask the high bits.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: David S. Miller <davem@davemloft.net>
