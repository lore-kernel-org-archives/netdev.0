From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/15] vmxnet3: fix decimal printf format specifiers
 prefixed with 0x
Date: Wed, 06 Aug 2014 14:13:58 -0700 (PDT)
Message-ID: <20140806.141358.1388775651933022161.davem@davemloft.net>
References: <1407300161-32600-1-git-send-email-hans@hanshq.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hans@hanshq.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407300161-32600-1-git-send-email-hans@hanshq.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hans Wennborg <hans@hanshq.net>
Date: Tue,  5 Aug 2014 21:42:41 -0700

> The prefix suggests the number should be printed in hex, so use
> the %x specifier to do that.
> 
> Found by using regex suggested by Joe Perches.
> 
> Signed-off-by: Hans Wennborg <hans@hanshq.net>

Applied, thank you.
