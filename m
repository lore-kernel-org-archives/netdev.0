From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 23:43:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929214350.GA26714@wotan.suse.de>
References: <20040928223344.GC2975@wotan.suse.de> <Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu> <20040929140016.7ffa4e8b.davem@davemloft.net> <415B2647.8080803@us.ibm.com> <20040929142252.393a976d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nivedita Singhvi <niv@us.ibm.com>, jheffner@psc.edu, ak@suse.de,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040929142252.393a976d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I need to see the crash folks are seeing.  Does it only happen
> when you have tcpdump attached to the interface running the
> test?  Does it happen only on the sender or the receiver

It happens without tcpdump too.

> in the netperf test?  Those would be a good clues, indicating

The sender first gets slow, then eventually crashes.

-Andi
