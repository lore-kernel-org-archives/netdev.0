From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 13:50:01 +0100
Message-ID: <20041207125001.GA26644@soohrt.org>
References: <20041206205305.GA11970@soohrt.org> <20041206134849.498bfc93.davem@davemloft.net> <20041206224107.GA8529@soohrt.org> <41B58A58.8010007@draigBrady.com> <20041207112139.GA3610@soohrt.org> <16821.42080.932184.167780@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: P@draigBrady.com, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16821.42080.932184.167780@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Robert Olsson wrote:
> Well my experience is that it very hard not to say almost impossible to 
> extrapolate idle cpu into any network system capacity. I guess this is 
> what you are trying to do? 

Kinda, yes.
I'm trying to evaluate if the behaviour I'm seeing is expected, which
would heavily influence my choice of hardware/software for future
projects (and of course to optimize the current setup).

Currently I'm having problems capturing packets with tcpdump (lots of
"packets dropped by kernel") which indicates to me that there's
genuinely not much (enough) idle time sitting around.

> Rather load and overload the system with traffic having the characteristics
> you expect as a bonus you will get some kind proof of robustness and 
> responsiveness a max load. There are tools for this type of tests.

Will do, that could take a couple of days though.

Cheers,
 Karsten
