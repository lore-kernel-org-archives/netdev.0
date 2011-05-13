From: Johannes Sixt <j6t@kdbg.org>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up
 hard right after logging in)
Date: Fri, 13 May 2011 20:47:26 +0200
Message-ID: <4DCD7CBE.9010409@kdbg.org>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com> <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com> <BANLkTi=dL+KyQ3Bm58_Uj4LP9WSpbzAfJA@mail.gmail.com> <BANLkTi=NdVUUZ=_bACzyeMGS3JWs0EMbWA@mail.gmail.com> <BANLkTimE2GkkhcFZtNrYZASWp0LDhUx=GQ@mail.gmail.com> <BANLkTinyzBnksHk_rt8K2pmg90q5WyZX3w@mail.gmail.com> <BANLkTinVT=9+-HhwXcyLBwrnhX9F9Qz3ww@mail.gmail.com> <4DCD79A0.7000500@kdbg.org> <BANLkTi=smoaARKyzWxFjid-E7qehmyAX8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Lutomirski <luto@mit.edu>,
	Christian Couder <christian.couder@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org, Shuang He <shuang.he@intel.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=smoaARKyzWxFjid-E7qehmyAX8w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 13.05.2011 20:41, schrieb Linus Torvalds:
> On Fri, May 13, 2011 at 11:34 AM, Johannes Sixt <j6t@kdbg.org> wrote:
>>   git bisect good v2.6.38
> 
> When you say that v2.6.38 is good, that means that everything that can
> be reached from 2.6.38 is good.
> 
> NOT AT ALL the same thing as "git bisect requires v2.6.38" would be.
> 
> Think about it. It's the "reachable from v2.6.38" vs "cannot reach
> v2.6.38" difference. That's a HUGE difference.

Oops, you're right, I got it upside-down.

Thanks,
-- Hannes
