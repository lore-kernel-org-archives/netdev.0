From: Baolin Wang <baolin.wang@linaro.org>
Subject: Re: [PATCH v5 00/24] Convert the posix_clock_operations and k_clock
 structure to ready for 2038
Date: Mon, 15 Jun 2015 10:27:53 +0800
Message-ID: <CAMz4ku+yt=DWctKj+S4mTCKna-CyfXkhJhWLkJecBBXed39A7Q@mail.gmail.com>
References: <cover.1434079262.git.baolin.wang@linaro.org>
	<alpine.DEB.2.11.1506121512180.3786@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd@arndb.de>,
	John Stultz <john.stultz@linaro.org>,
	Heena Sirwani <heenasirwani@gmail.com>,
	Xunlei Pang <pang.xunlei@linaro.org>, peterz@infradead.org,
	rafael.j.wysocki@intel.com, Greg KH <gregkh@linuxfoundation.org>,
	Richard Cochran <richardcochran@gmail.com>,
	benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	linux390@de.ibm.com, rth@twiddle.net, riel@redhat.com,
	cl@linux.com, tj@kernel.org,
	=?UTF-8?B?RnLDqWTDqXJpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>,
	Andrew Hunter <ahh@google.com>, Paul Turner <pjt@google.com>,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-arch@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Serge Hallyn <serge.hallyn@canonical.com>,
	James Morris <james.l.morris@oracle.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Paul
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1506121512180.3786@nanos>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12 June 2015 at 21:16, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Fri, 12 Jun 2015, Baolin Wang wrote:
>
> Sigh. Again threading of the series failed. Some patches are, the
> whole series is not. Can you please get your tools straight?
>
> You neither managed to cc me on the security patch.
>
>> - Modify the subject line and the changelog:
>
>>   timekeeping: Change the implementation of timekeeping_clocktai()
>
> Sigh. How is that better than the previous one? It's more accurate,
> but equally useless.
>
> And of course you did not address my request to change the macro mess
> in
>
>>   posix-timers: Introduce {get,put}_timespec and {get,put}_itimerspec
>
> according to the discussion with Arnd.
>
> Thanks,
>
>         tglx

Hi Thomas,

Thanks for your comments, and i'll fix these problems you point out.

-- 
Baolin.wang
Best Regards
