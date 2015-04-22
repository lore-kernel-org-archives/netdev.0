From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods with timespec64 type for k_clock structure
Date: Wed, 22 Apr 2015 17:38:28 +0200
Message-ID: <2088991.9ogxlI08JT@wuerfel>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <2500914.bVUENZ0dAZ@wuerfel> <20150422151445.GA2165@macpro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: y2038@lists.linaro.org, pang.xunlei@linaro.org,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>, cl@linux.com,
	Ingo Molnar <mingo@kernel.org>, heenasirwani@gmail.com,
	linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
	mpe@ellerman.id.au, rafael.j.wysocki@intel.com, ahh@google.com,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, pjt@google.com,
	riel@redhat.com, richardcochran@gmail.com,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>, rth@twiddle.net,
	Baolin Wang <baolin.wang@linaro.org>,
	gregkh@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	linux390@de.ibm.com, linuxppc-
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20150422151445.GA2165@macpro.local>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 22 April 2015 17:14:47 Luc Van Oostenryck wrote:
> On Wed, Apr 22, 2015 at 03:50:45PM +0200, Arnd Bergmann wrote:
> > On Wednesday 22 April 2015 13:07:44 Arnd Bergmann wrote:
> ...
> > select, old_selct, pselect6: deprecated
> 
> Small, copy&paste error here for pselect6.
> 

Right, that should have been poll.

	Arnd
