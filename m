From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] netpoll: use DEFINE_STATIC_SRCU() to define
 netpoll_srcu
Date: Sun, 17 Mar 2013 12:43:10 -0400 (EDT)
Message-ID: <20130317.124310.989927335904954119.davem@davemloft.net>
References: <1363366257-4886-1-git-send-email-laijs@cn.fujitsu.com>
	<1363366257-4886-5-git-send-email-laijs@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, amwang@redhat.com,
	nhorman@tuxdriver.com, edumazet@google.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363366257-4886-5-git-send-email-laijs@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Sat, 16 Mar 2013 00:50:52 +0800

> DEFINE_STATIC_SRCU() defines srcu struct and do init at build time.
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Applied.
