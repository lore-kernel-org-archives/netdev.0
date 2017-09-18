From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Convert int functions to bool
Date: Mon, 18 Sep 2017 11:40:18 -0700 (PDT)
Message-ID: <20170918.114018.173328234898891446.davem@davemloft.net>
References: <f9e044957a949f10d472a48437f62649ea57f858.1505336212.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f9e044957a949f10d472a48437f62649ea57f858.1505336212.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 13 Sep 2017 13:58:15 -0700

> Global function ipv6_rcv_saddr_equal and static functions
> ipv6_rcv_saddr_equal and ipv4_rcv_saddr_equal currently return int.
> 
> bool is slightly more descriptive for these functions so change
> their return type from int to bool.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
