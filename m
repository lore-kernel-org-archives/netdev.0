From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] xen-netback: switch to use
 skb_partial_csum_set()
Date: Fri, 12 Apr 2013 14:59:02 -0400 (EDT)
Message-ID: <20130412.145902.808700335606305579.davem@davemloft.net>
References: <1365662129-38031-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365662129-38031-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 11 Apr 2013 14:35:29 +0800

> Switch to use skb_partial_csum_set() to simplify the codes.
> 
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
