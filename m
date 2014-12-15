From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cirrus: cs89x0: fix time comparison
Date: Mon, 15 Dec 2014 11:44:40 -0500 (EST)
Message-ID: <20141215.114440.1645405042049378253.davem@davemloft.net>
References: <20141214083418.GA25910@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, julia.lawall@lip6.fr, himangi774@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: asaf.vertz@tandemg.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141214083418.GA25910@ubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asaf Vertz <asaf.vertz@tandemg.com>
Date: Sun, 14 Dec 2014 10:34:18 +0200

> To be future-proof and for better readability the time comparisons are
> modified to use time_before, time_after, and time_after_eq instead of
> plain, error-prone math.
> 
> Signed-off-by: Asaf Vertz <asaf.vertz@tandemg.com>

Applied.
