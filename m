From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: add support for IPv6 checksum
 offloads
Date: Sun, 16 Jul 2017 16:36:27 -0700 (PDT)
Message-ID: <20170716.163627.1466579407318984833.davem@davemloft.net>
References: <1499385430-11659-1-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1499385430-11659-1-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Thu,  6 Jul 2017 16:57:10 -0700

> The original code didn't handle non-IPv4 packets very well, so the
> offload advertising had to be scaled back down to just IP.  Here we
> add the bits needed to support TCP and UDP packets over IPv6 and
> turn the offload advertising back on.
> 
> Orabug: 26289579
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>

Applied.
