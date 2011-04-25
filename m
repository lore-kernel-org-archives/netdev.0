From: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: LPC2011 Scaling Micro Conf
Date: Sun, 24 Apr 2011 17:45:04 -0700
Message-ID: <20110425004504.GA14037@linux.vnet.ibm.com>
Reply-To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rp-hdFA07tZRcq1sMc9nBuxBA@public.gmane.org,
	linaro-dev-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	ltt-dev-33AaDErTWvBVxDZ2/Zk0YoryAYyacSEB@public.gmane.org
Return-path: <linaro-dev-bounces-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.linaro.org/mailman/options/linaro-dev>,
	<mailto:linaro-dev-request-cunTk1MwBs8s++Sfvej+rw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linaro.org/pipermail/linaro-dev>
List-Post: <mailto:linaro-dev-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>
List-Help: <mailto:linaro-dev-request-cunTk1MwBs8s++Sfvej+rw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linaro.org/mailman/listinfo/linaro-dev>,
	<mailto:linaro-dev-request-cunTk1MwBs8s++Sfvej+rw@public.gmane.org?subject=subscribe>
Sender: linaro-dev-bounces-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
Errors-To: linaro-dev-bounces-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

Given the increasing numbers of CPUs on low-cost servers as well as
the appearance of SMP hand-held battery-powered devices, Linux Plumbers
2011 will feature a Scaling track, with topics including the following:

- What can the kernel do to help applications perform and scale better?
- What can applications do to help the kernel perform and scale better?
- Memory footprint:
  + 100MB here, 100MB there, pretty soon you are talking real memory!
  + Improving performance by decreasing icache and dcache footprint.
- Limits to scalability:
  + Technological limitations, especially hardware.
  + Complexity/maintainability limitations.
- Handling of non-CPU computational hardware (GPGPUs, crypto HW, etc.)
  + Can the kernel make good use of non-CPU computational hardware?
  + How best to enable user applications to use them?
- Dealing with the numerous remaining "little kernel locks"

The intended audience is developers interested in performance and
scalability throughout the Linux plumbing.

The deadline is April 30th.  Please submit your proposals, whether to
Scaling or to other microconferences, at:

	http://www.linuxplumbersconf.org/2011/ocw/events/LPC2011MC/proposals

The general track is also open for submissions until April 30th:

	http://www.linuxplumbersconf.org/2011/ocw/events/LPC2011/proposals

Either way, we look forward to seeing your submissions!

							Thanx, Paul
