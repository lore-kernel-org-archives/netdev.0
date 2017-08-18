From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: inet: diag: expose sockets cgroup classid
Date: Fri, 18 Aug 2017 16:11:00 -0700 (PDT)
Message-ID: <20170818.161100.475980595210977152.davem@davemloft.net>
References: <20170817003910.15904-1-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: alexander.levin@verizon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170817003910.15904-1-alexander.levin@verizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Date: Thu, 17 Aug 2017 00:35:11 +0000

> From: "Levin, Alexander (Sasha Levin)" <alexander.levin@one.verizon.com>
> 
> This is useful for directly looking up a task based on class id rather than
> having to scan through all open file descriptors.
> 
> Signed-off-by: Sasha Levin <alexander.levin@verizon.com>

Applied to net-next, thanks.
