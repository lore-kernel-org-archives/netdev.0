From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: ixgb problem
Date: Sun, 6 Mar 2005 14:15:27 -0500
Message-ID: <20050306191527.GA9610@havoc.gtf.org>
References: <422B54AF.4060401@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Baruch Even <baruch@ev-en.org>
Content-Disposition: inline
In-Reply-To: <422B54AF.4060401@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2005 at 07:06:23PM +0000, Baruch Even wrote:
> I'm running a test of iperf with a window of 16MB, at first the 
> performance shows about 3.2Gbps rate (which sucks by itself, but that's 
> another issue), after some time, usually 30-40 seconds, but sometimes 
> 100 seconds, the performance drops to almost nothing, about 60Kbps.

If you could get sysrq-p and sysrq-t output, that would be useful.

Also, check and see what your CPU load is, at the time.

	Jeff
