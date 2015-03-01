From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pasemi: Use setup_timer and mod_timer
Date: Sun, 01 Mar 2015 14:00:44 -0500 (EST)
Message-ID: <20150301.140044.2112633140577210266.davem@davemloft.net>
References: <20150227185059.GA20385@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150227185059.GA20385@vaishali-Ideapad-Z570>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Sat, 28 Feb 2015 00:20:59 +0530

> Use timer API functions setup_timer and mod_timer instead
> of structure assignments as they are standard way to set
> the timer and to update the expire field of an active timer
> respectively.
> 
> This is done using Coccinelle and semantic patch used for
> this is as follows:
 ...
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied.
