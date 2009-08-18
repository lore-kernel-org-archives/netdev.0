From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2009-08-18
Date: Tue, 18 Aug 2009 16:29:52 -0700 (PDT)
Message-ID: <20090818.162952.161230185.davem@davemloft.net>
References: <20090818151436.GA2768@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752222AbZHRX3m@vger.kernel.org>
In-Reply-To: <20090818151436.GA2768@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 18 Aug 2009 11:14:37 -0400

> Dave,
> 
> Two more for 2.6.31...
> 
> The one from Johannes is actually already in net-next-2.6, but it has
> since been reported to cause a possible irq lock inversion dependency in
> 2.6.31-rc6, as described here:
> 
> 	http://marc.info/?l=linux-wireless&m=125052198303537&w=2
> 
> The one from me fixes a minor bounds checking problem in orinoco, as
> reported by Dan Carpenter.  It is simple and obvious.

Pulled, thanks John.
