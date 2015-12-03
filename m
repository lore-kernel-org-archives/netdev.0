From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/neighbour: fix crash at dumping device-agnostic
 proxy entries
Date: Thu, 03 Dec 2015 00:08:47 -0500 (EST)
Message-ID: <20151203.000847.523148860681358334.davem@davemloft.net>
References: <144892168886.1956.12514575216454077256.stgit@zurg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: koct9i@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <144892168886.1956.12514575216454077256.stgit@zurg>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 01 Dec 2015 01:14:48 +0300

> Proxy entries could have null pointer to net-device.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Fixes: 84920c1420e2 ("net: Allow ipv6 proxies and arp proxies be shown with iproute2")

Applied and queued up for -stable.
