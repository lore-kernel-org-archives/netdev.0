From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent
 2.4.x/2.6.x kernels
Date: Thu, 29 Sep 2005 11:16:47 -0700 (PDT)
Message-ID: <20050929.111647.65068628.davem@davemloft.net>
References: <Pine.LNX.4.61.0509281223560.30951@ionlinux.tower-research.com>
	<20050929151729.GA2158@ms2.inr.ac.ru>
	<200509291204.29393.jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, lists@limebrokerage.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org, gautran@mrv.com
Return-path: <linux-net-owner@vger.kernel.org>
To: jheffner@psc.edu
In-Reply-To: <200509291204.29393.jheffner@psc.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Thu, 29 Sep 2005 12:04:28 -0400

> Has anyone looked at the patch I sent out on Sept 9?  It goes a few steps 
> further, addressing some additional problems.  Original message below.

It's in my inbox pending review, so it's not forgotten :-)

My gut instinct right now is that we should put Alexey's
2-liner in for 2.6.14 et al. then be thinking about your
scheme for 2.6.15
