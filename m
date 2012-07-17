From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: cgroup: fix access the unallocated memory in
 netprio cgroup
Date: Mon, 16 Jul 2012 23:01:05 -0700 (PDT)
Message-ID: <20120716.230105.2069123905936956283.davem@davemloft.net>
References: <1342079415-9631-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20120712105611.GA7055@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	edumazet@google.com
To: nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120712105611.GA7055@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 12 Jul 2012 06:56:11 -0400

> On Thu, Jul 12, 2012 at 03:50:15PM +0800, Gao feng wrote:
>> there are some out of bound accesses in netprio cgroup.
 ...
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 

Applied to 'net', thanks.
