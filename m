From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: Remove unused variable in route.c
Date: Thu, 05 Oct 2017 21:17:05 -0700 (PDT)
Message-ID: <20171005.211705.976817989137040544.davem@davemloft.net>
References: <20171004195949.GA39492@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.levin@one.verizon.com
To: devtimhansen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004195949.GA39492@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Hansen <devtimhansen@gmail.com>
Date: Wed, 4 Oct 2017 15:59:49 -0400

> int rc is unmodified after initalization in net/ipv4/route.c, this patch simply cleans up that variable and returns 0.
> 
> This was found with coccicheck M=net/ipv4/ on linus' tree.
> 
> Signed-off-by: Tim Hansen <devtimhansen@gmail.com>

Applied to net-next.
