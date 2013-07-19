From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mod_timer: list_add corruption: WARNING: CPU: 1 PID: 0 at
 lib/list_debug.c:33 __list_add+0xbe/0xd0()
Date: Fri, 19 Jul 2013 18:38:55 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1307191834460.4089@ionos.tec.linutronix.de>
References: <51E557C0.2060602@linux.vnet.ibm.com>  <alpine.DEB.2.02.1307191323150.4089@ionos.tec.linutronix.de>  <51E92769.7090106@linux.vnet.ibm.com>  <alpine.DEB.2.02.1307191523050.4089@ionos.tec.linutronix.de> <1374241882.26476.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Cong Wang <amwang@redhat.com>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374241882.26476.5.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Jul 2013, Eric Dumazet wrote:
> 
> I guess following should help 

Applying the empty patch does not work very well. Could you try again
after the caffeine reached your brain, please ? :)

Thanks,

	tglx
