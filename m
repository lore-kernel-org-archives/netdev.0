From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 14:11:25 +0100
Message-ID: <20041207131125.GB26644@soohrt.org>
References: <20041206205305.GA11970@soohrt.org> <20041206134849.498bfc93.davem@davemloft.net> <20041206224107.GA8529@soohrt.org> <41B58A58.8010007@draigBrady.com> <20041207112139.GA3610@soohrt.org> <16821.42080.932184.167780@robur.slu.se> <20041207125001.GA26644@soohrt.org> <1102424673.1093.124.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102424673.1093.124.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal wrote:
> On Tue, 2004-12-07 at 07:50, Karsten Desler wrote:
> 
> > Currently I'm having problems capturing packets with tcpdump (lots of
> > "packets dropped by kernel") which indicates to me that there's
> > genuinely not much (enough) idle time sitting around.
> > 
> 
> Ah, more hints. So you are not trying to forward - rather just packet
> capturing?

forward/routing is the goal.

I was just trying to capture a tcpdump to analyze the traffic to
generate something that could emulate the trafficpattern for further
testing in a non-production environment.

Cheers,
 Karsten
