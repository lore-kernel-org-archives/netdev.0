From: george anzinger <george@mvista.com>
Subject: Re: Network oops
Date: Fri, 21 Jun 2002 07:16:24 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <aevcov$fvj$2@main.gmane.org>
References: <20020609.213150.32126725.davem@redhat.com>
		<3D042F8F.72764243@mvista.com>
		<3D120EAE.5A0D365E@mvista.com> <20020620.173805.55219901.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   ak@muc.de, pekkas@netcore.fi, andrew.r.cress@intel.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
> I don't understand, you've completely turned the preemption model of
> the kernel upside down and you want _US_ to debug this for you?

You could look at it this way :)

On the other hand, I prefer to think of the linux community as a group of folks working on making one of the best OSs on the planet even better.  Its adoption by more and more companies attests to its place in the world.  We who work on it, IMHO, should cooperate with each other in our efforts to make the system even better.  Sure we will disagree about some of the things others are doing and thus the need for some central control of the system.  For this we are indebted to Linus.  And we may not have time to spend working on the system when others would most like us to, but that is the nature
of life and we should respect others in this regard.

So while I would very much like your help, I understand that you may be busy with other things at this time and not have the time.  Still, I must ask, just as others ask of me.
> 
> This is a lot of work, work I personally don't have time for.

I can understand and accept that.

> It requires a full audit of the networking in the new preemption
> environment.

Any pointers on what to look for would be welcome.

-- 
George Anzinger   george@mvista.com
High-res-timers:  http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch: http://www.kernel.org/pub/linux/kernel/people/rml
