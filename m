From: jamal <hadi@cyberus.ca>
Subject: Re: memory leak in net/sched/ipt.c?
Date: 23 Mar 2005 09:12:48 -0500
Message-ID: <1111587168.1072.4.camel@jzny.localdomain>
References: <E1DE44X-0001QM-00@gondolin.me.apana.org.au>
	 <1111581618.1088.72.camel@jzny.localdomain>
	 <20050323125516.GP3086@postel.suug.ch>
	 <1111583497.1089.92.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0503231438290.10048@yvahk01.tjqt.qr>
	 <1111586750.1075.0.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
In-Reply-To: <1111586750.1075.0.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Actually its well documented even on the man pages - so should have not
even have bothered discussing it;-> Should get new brand of coffee.
Apologies for unecessarily abused electrons - which means dont 
respond ;->

cheers,
jamal

On Wed, 2005-03-23 at 09:05, jamal wrote:
> On Wed, 2005-03-23 at 08:40, Jan Engelhardt wrote:
> > >I have seen people put little comments of "kfree will work if you
> > >pass it NULL" - are you saying such assumptions exist all over
> > >net/sched?
> > 
> > Not only net/sched. The C standard requires that free(NULL) works.
> 
> Thanks for clarifying this.
> 
> cheers,
> jamal
> 
> 
> 
