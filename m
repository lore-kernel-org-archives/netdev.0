From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: smc91c92_cs: Use setup_timer and mod_timer
Date: Sun, 01 Mar 2015 13:55:38 -0500 (EST)
Message-ID: <20150301.135538.775778858693676108.davem@davemloft.net>
References: <20150227181024.GA20055@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150227181024.GA20055@vaishali-Ideapad-Z570>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Fri, 27 Feb 2015 23:40:24 +0530

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
