From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-02-15
Date: Wed, 15 Feb 2012 14:50:39 -0500 (EST)
Message-ID: <20120215.145039.1816967174435860741.davem@davemloft.net>
References: <20120215192106.GI4379@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120215192106.GI4379@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 15 Feb 2012 14:21:06 -0500

> Here are two more fixes intended for 3.3.  One changes the non-error
> return code for a routine in rtlwifi -- it had been masking an error
> condition that could lead to a divide by zero.  The other moves a
> routine inside of a locked critical section to avoid a "BUG: rwlock bad
> magic".
> 
> Please let me know if there are problems!

Pulled.
