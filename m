From: Andi Kleen <ak@suse.de>
Subject: Re: Current 2.6.x TSO state
Date: Sat, 2 Oct 2004 01:19:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001231939.GC23046@wotan.suse.de>
References: <20040930213221.06a3f5b3.davem@davemloft.net> <20041001121123.19511403.ak@suse.de> <20041001124733.1ac4266a.davem@davemloft.net> <20041001195146.GA23046@wotan.suse.de> <20041001125643.30c6830f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com, jheffner@psc.edu,
        herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041001125643.30c6830f.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> As mentioned, the TCP receive buffer auto-tuning takes care
> of all of this in 2.6.6 and later.  It's just 2.6.5 doesn't

How do you explain the 2-4MB/s less with manually increased 
receive buffers? 

-Andi
