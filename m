From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Sun, 05 Dec 2004 16:30:33 -0800
Message-ID: <1102293033.3343.152.camel@sfeldma-mobl.dsl-verizon.net>
References: <Pine.LNX.4.44.0412052230410.13794-100000@papput.nsc.liu.se>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ganesh.venkatesan@intel.com, john.ronciak@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Kjellstroem <cap@nsc.liu.se>
In-Reply-To: <Pine.LNX.4.44.0412052230410.13794-100000@papput.nsc.liu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-05 at 13:39, Peter Kjellstroem wrote:
> this is the original fix and triggers for both e1000_82547 (your 547EI 
> right?) and e1000_82547_rev_2 (my 547GI). If your NIC can't stand the fix 
> and mine needs it isn't the obvious solution the following?

Ganesh/John, what do you think?  Is there a clear dividing line between
82547EI and 82547GI wrt this issue?  If so, could Peter's patch go in?

-scott
