From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Thu, 15 Mar 2007 13:31:37 -0400
Message-ID: <20070315173137.GJ22466@csclub.uwaterloo.ca>
References: <20070220000231.GM7585@csclub.uwaterloo.ca> <20070220.203413.260790539.takada@mbf.nifty.com> <20070220144823.GN7585@csclub.uwaterloo.ca> <20070315.143939.193680310.takada@mbf.nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: takada <takada@mbf.nifty.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750782AbXCORbi@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070315.143939.193680310.takada@mbf.nifty.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 02:39:39PM +0900, takada wrote:
> Hiroshi Miura posted `Geode out-of-order store enables' patch in Jun, 2003.
> There is http://lkml.org/lkml/2003/6/5/57 .
> OOSTORE was enabled at this point in time. It seems to have disappeared somewhere.

I believe the patch was rejected as 'not required' since the data sheet
is not very clear on that "feature".

> BTW, I use MediaGX with kernel 2.6.20(and 2.6.20.3) and suspend2. When I resume 
> the PC and use the PC Card modem, PC is hungup. However, PC isn't hung up when
> I apply a WBINVD patch.
> I can't understand it whether there is problem in resume of suspend2 or MediaGX
> or both. Many drivers lack support for resume on my PC.

Which patch are you refering to?

--
Len Sorensen
