From: Andi Kleen <ak@suse.de>
Subject: Re: Hang when testing with AMD64 with Tg3
Date: Tue, 5 Oct 2004 02:15:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005001527.GB13106@wotan.suse.de>
References: <1096935071.22155.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <1096935071.22155.6.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 04, 2004 at 05:11:11PM -0700, Stephen Hemminger wrote:
> Doing simple iperf test on new opteron with tg3 against existing Xeon
> system.  I am seeing something wierd, the connection hangs right away.
> Is this a TSO bug.  
> 
> Sender: BK latest (2.6.9-rc3) Tg3 (XX.YY.250.3)
> Receiver: BK + netdev(jeffm) + dave's latest e100 (XX.YY.1.73)
> 
> Both machines are directly connected with a netgear 100mbit switch.


I don't see things like this on my boxes with rc3, also with tg3s.

Of what nature is the hang? Does the machine crash?

-Andi
