From: Karen Shaeffer <shaeffer@neuralscape.com>
Subject: Re: cheap 4-port tulip-based cards available
Date: Sat, 19 Oct 2002 14:42:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021019144236.C11659@synapse.neuralscape.com>
References: <slrnaqpajf.2ph.lunz@stoli.localnet> <3DB1C96B.4070505@candelatech.com> <20021019141417.A11659@synapse.neuralscape.com> <3DB1CF5A.9080701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3DB1CF5A.9080701@candelatech.com>; from greearb@candelatech.com on Sat, Oct 19, 2002 at 02:32:10PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 19, 2002 at 02:32:10PM -0700, Ben Greear wrote:
> Karen Shaeffer wrote:
> > On Sat, Oct 19, 2002 at 02:06:51PM -0700, Ben Greear wrote:
> > 
> I make traffic generators out of them (www.candelatech.com)
> 
> They are also good for firewalls and routers, as well as more
> exotic network devices.  Using linux for a switch does not make so
> much sense these days when you can buy a 16 port switch for under $100,
> but with bridging code it can be done.

Actually, I think linux based switches could be quite interesting in
a pipelined, beowulf-like or openmosix cluster. (Of course, GigE would
probably be employed rather than FE.) You could then integrate traffic
shaping/monitoring functionality into the switch that could be designed
to interoperate with the cluster nodes to assist in optimizing data flow
and subsequent processing. With openmosix, this could also be used to
migrate processes towards optimum node placement, based on network
traffic analysis as well as nodal resource availability.

It's a subject I've been thinking about quite a bit lately. This is most
interesting in adaptive, pipelined clusters that will be processing
real-time streaming data. That's certainly a niche market at the present
time.

cheers,
Karen
-- 
 Karen Shaeffer
 Neuralscape; Santa Cruz, Ca. 95060
 shaeffer@neuralscape.com  http://www.neuralscape.com
