From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance tests
Date: Tue, 10 Jun 2003 07:23:28 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610071638.R37090@shell.cyberus.ca>
References: <20030610075732.GD23009@netnation.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ralph+d@istop.com, CIT/Paul <xerox@foonet.net>,
   "'David S. Miller'" <davem@redhat.com>,
   "fw@deneb.enyo.de" <fw@deneb.enyo.de>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030610075732.GD23009@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 10 Jun 2003, Simon Kirby wrote:

[some good stuff deleted]

Simon,
I havent looked at your data in details; i will. Someone like Robert
would be able to snuff it much faster than i do. I just wanna say thanks
for the effort, I will spend time catching up with you folks.
It is clear that our next hurudle is gc.
Do you have profiles for your data? Profiles would be nice to collect
as well.

> In any case, setting gc_min_interval to 0 definitely helped, but I
> suspect Dave's patches will make a bigger difference.  Next up is
> 2.5.70-bk14 and 2.5.70-bk14+davem's stuff from yesterday.
>

Also since you are doing all that work post the kernels somewhere so
people like foo can grab them and test as well.

cheers,
jamal
