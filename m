From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: TCP throttling
Date: Tue, 20 Sep 2005 07:19:03 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0509200717410.21650@uplift.swm.pp.se>
References: <200509190646.57579.a1426z@gawab.com> <20050919112008.17ad14f5@dxpl.pdx.osdl.net>
 <200509200654.23703.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@osdl.org>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Al Boldi <a1426z@gawab.com>
In-Reply-To: <200509200654.23703.a1426z@gawab.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2005, Al Boldi wrote:

> Could you suggest sane values for 2.4/2.6 on a 100mbit link?

Go for approx 2-8 megs of TCP window size and buffers.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
