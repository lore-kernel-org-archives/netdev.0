From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Tue, 28 Sep 2004 16:10:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096413009.27967.1.camel@localhost.localdomain>
References: <1093799632.1073.410.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093799632.1073.410.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-08-29 at 13:13 -0400, jamal wrote:
> 
> The requeue event is useful in finding out when a device is overloaded
> on the egress (bus or bandwidth).
> Atached patch introduces this. I would have used the overlimit bits
> but at the moment thats being used for different semantical reasons.
> I have not done extensive testing on it. 
> 
> Opinions welcome - If all is good, Dave please apply.

Dave, what happened to this?  I put the stuff into iproute2 but the
requeue stat never made it into 2.6.  Is it a bad idea?
