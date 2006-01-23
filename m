From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH 00/00] pktgen: refinements and small fixes.
Date: Mon, 23 Jan 2006 18:00:42 +0100
Message-ID: <17365.3002.480408.154987@robur.slu.se>
References: <20060123134140.b04ad994.lcapitulino@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, lkml <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964837AbWAWRW6@vger.kernel.org>
To: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
In-Reply-To: <20060123134140.b04ad994.lcapitulino@mandriva.com.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Luiz Fernando Capitulino writes:

 >  [PATCH 00/02] pktgen: Ports thread list to Kernel list implementation.
 >  [PATCH 00/03] pktgen: Fix kernel_thread() fail leak.
 >  [PATCH 00/04] pktgen: Fix Initialization fail leak. 
 > 

 >  But I'm sending these patches first, just to know if I'm doing something
 > wrong.

 Thanks!

 Looks interesting. Yes of course better to use kernel list functions. I'll 
 patch my lab version and run through some tests. 
 
 Yes keep on hacking...

 Cheers.
					--ro
