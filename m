From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tuntap: fix sparse warning
Date: Mon, 17 Dec 2012 20:49:19 -0800 (PST)
Message-ID: <20121217.204919.1174594015682114662.davem@davemloft.net>
References: <1355799627-55529-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fengguang.wu@intel.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355799627-55529-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 18 Dec 2012 11:00:27 +0800

> Make tun_enable_queue() static to fix the sparse warning:
> 
> drivers/net/tun.c:399:19: sparse: symbol 'tun_enable_queue' was not declared. Should it be static?
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
