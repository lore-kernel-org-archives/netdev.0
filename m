From: Andi Kleen <ak@suse.de>
Subject: Re: FYI: Etherleak
Date: Fri, 10 Jan 2003 03:12:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030110021241.GA32653@wotan.suse.de>
References: <D71BEAC27500D51199DF0002B328BA8D4FBF2B@ivexs1.intruvert.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Yan-Fa Li <yan@intruvert.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <D71BEAC27500D51199DF0002B328BA8D4FBF2B@ivexs1.intruvert.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 09, 2003 at 05:49:47PM -0800, Yan-Fa Li wrote:
> An interesting report into frame-padding information leakage violations in
> ethernet drivers.  The authors use linux drivers in their examples.
> 
> http://www.atstake.com/research/advisories/2003/atstake_etherleak_report.pdf

It's an old bug, it was discussed years ago on l-k.

Unfortunately the drivers weren't fixed at that time.

-Andi
