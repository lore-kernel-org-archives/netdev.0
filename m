From: jamal <hadi@cyberus.ca>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: 30 Aug 2004 22:37:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093919823.1043.80.camel@jzny.localdomain>
References: <1093799632.1073.410.camel@jzny.localdomain>
	 <20040830144033.2265a6e6.davem@redhat.com>
	 <1093904088.1043.12.camel@jzny.localdomain>
	 <20040830154430.769d1d59.davem@redhat.com>
	 <1093906592.1037.32.camel@jzny.localdomain>
	 <20040830160052.548c4846.davem@redhat.com>
	 <1093916592.1037.51.camel@jzny.localdomain>
	 <20040830191716.0d002f91.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040830191716.0d002f91.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-30 at 22:17, David S. Miller wrote:
> On 30 Aug 2004 21:43:13 -0400
> jamal <hadi@cyberus.ca> wrote:

> > Not sure i parsed that. You mean the tc_stats in user space will be the new 
> > one.
> 
> Yes, that's his idea.  This way on older kernel the "new" statistics
> just show up as zero.

thmart. Lets go with this then. Steve, do you wanna take it from here
with the iproute2 patch i sent or you want me to generate a new one? Now
how do we tell all other people who have written netlink apps
to beware?

cheers,
jamal
