From: Thomas Graf <tgraf@suug.ch>
Subject: Re: iptables breakage WAS(Re: dummy as IMQ replacement
Date: Fri, 25 Mar 2005 22:01:02 +0100
Message-ID: <20050325210102.GG3086@postel.suug.ch>
References: <1111625608.1037.16.camel@jzny.localdomain> <424212F7.10106@dsl.pipex.com> <1111663947.1037.24.camel@jzny.localdomain> <1111665450.1037.27.camel@jzny.localdomain> <4242DFB5.9040802@dsl.pipex.com> <1111749220.1092.457.camel@jzny.localdomain> <42446DB2.9070809@dsl.pipex.com> <1111781443.1092.631.camel@jzny.localdomain> <20050325202014.GE3086@postel.suug.ch> <1111783686.1089.661.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>,
        Harald Welte <laforge@gnumonks.org>, Patrick McHardy <kaber@trash.net>,
        Remus <rmocius@auste.elnet.lt>, netdev <netdev@oss.sgi.com>,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Damion de Soto <damion@snapgear.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111783686.1089.661.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1111783686.1089.661.camel@jzny.localdomain> 2005-03-25 15:48
> On Fri, 2005-03-25 at 15:20, Thomas Graf wrote:
> 
> > 7/10 because the meta ematch could make great use of this. Matching
> > on netfilter meta data is in my local tree but I guess I won't
> > have time to test everything in the next 2 weeks so it will probably
> > be too late for 2.6.12.
> 
> /me looks at Thomas ;-> Could you be convinced to do this so i can play
> with my ipsec toy? ;->

I can enqueue it to the following working queue, won't be dequeued
for quite a while though.
 resolve an open htb+gred issue
 libqsearch thing + ematch
 push meta ematch changes
 libnl + netconfig release

If you want to see results soon, look for someone else. ;->
