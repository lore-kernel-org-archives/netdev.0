From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v5 00/24] Convert the posix_clock_operations and k_clock
 structure to ready for 2038
Date: Fri, 12 Jun 2015 15:16:11 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1506121512180.3786@nanos>
References: <lfywpz1987> <cover.1434079262.git.baolin.wang@linaro.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: arnd@arndb.de, john.stultz@linaro.org, heenasirwani@gmail.com,
	pang.xunlei@linaro.org, peterz@infradead.org,
	rafael.j.wysocki@intel.com, gregkh@linuxfoundation.org,
	richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com, rth@twiddle.net,
	riel@redhat.com, cl@linux.com, tj@kernel.org, fweisbec@gmail.com,
	ahh@google.com, pjt@google.com, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, james.l.morris@oracle.com,
	serge@hallyn.com, pmoore@redhat.com, tiwai@suse.de,
	jeffv@google.com, jlayton@primarydata.com, keescook@chromium.org,
	sds@tycho.nsa.gov, mark.d.rustad@intel.com,
	linux-security-module@vger.kernel.org, y2038@lists.linaro.org
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <cover.1434079262.git.baolin.wang@linaro.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Jun 2015, Baolin Wang wrote:

Sigh. Again threading of the series failed. Some patches are, the
whole series is not. Can you please get your tools straight?

You neither managed to cc me on the security patch.

> - Modify the subject line and the changelog:

>   timekeeping: Change the implementation of timekeeping_clocktai()

Sigh. How is that better than the previous one? It's more accurate,
but equally useless.

And of course you did not address my request to change the macro mess
in

>   posix-timers: Introduce {get,put}_timespec and {get,put}_itimerspec

according to the discussion with Arnd.

Thanks,

	tglx
