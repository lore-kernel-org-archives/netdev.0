From: cliff white <cliffw@osdl.org>
Subject: Re: netif_rx packet dumping
Date: Tue, 22 Mar 2005 13:55:33 -0800
Message-ID: <20050322135533.55313a42@es175>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<20050303125556.6850cfe5.davem@davemloft.net>
	<1109884688.1090.282.camel@jzny.localdomain>
	<20050303132143.7eef517c@dxpl.pdx.osdl.net>
	<1109885065.1098.285.camel@jzny.localdomain>
	<20050303133237.5d64578f.davem@davemloft.net>
	<20050303135416.0d6e7708@dxpl.pdx.osdl.net>
	<Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu>
	<1109888811.1092.352.camel@jzny.localdomain>
	<20050303151606.3587394f@dxpl.pdx.osdl.net>
	<4227A23C.5050300@ev-en.org>
	<1109907956.1092.476.camel@jzny.localdomain>
	<42282098.8010506@ev-en.org>
	<1110203711.1088.1393.camel@jzny.localdomain>
	<422DCB14.1040805@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Baruch Even <baruch@ev-en.org>, netdev@oss.sgi.com
In-Reply-To: <422DCB14.1040805@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 08 Mar 2005 15:56:04 +0000
Baruch Even <baruch@ev-en.org> wrote:

> jamal wrote:
> > On Fri, 2005-03-04 at 03:47, Baruch Even wrote:
> > 
> >>jamal wrote:
> > 
> > 
[snip]
> 
> > So if i was you i would repeat 1.2 with the fix from 1.1 as well as
> > tying the NIC to one CPU. And it would be a good idea to present more
> > detailed results - not just tcp windows fluctuating (you may not need
> > them for the paper, but would be useful to see for debugging purposes
> > other parameters).
> 
> I'd be happy to hear what other benchmarks you would like to see, I 
> currently intend to add some ack processing time analysis and oprofile 
> information. With possibly showing the size of the ingress queue as a 
> measure as well.
> 
> Making it as thorough as possible is one of my goals. Input is always 
> welcome.

I am collecting network benchmarks/test in hope of doing some testing here at OSDL.
Would love to run your benchmark, if you wished to share.
cliffw

> 
> Baruch
> 


-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman
