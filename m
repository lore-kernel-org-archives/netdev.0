From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Fri, 7 Jan 2011 14:48:43 -0800
Message-ID: <AANLkTinANp+Jp8TPKzii6iZLUFpMyrXhmxYr42nZrXQU@mail.gmail.com>
References: <20110106.122003.233698077.davem@davemloft.net>
 <AANLkTi=7=_FyVsjA3vKEpg8RwfC=m-8QGfqa6ctxQday@mail.gmail.com>
 <20110107190656.GQ3702@decadent.org.uk> <AANLkTikwrHoOY4wvUp1qn-OT=EjZesSNR29US1ERc0o2@mail.gmail.com>
 <20110107215505.GA1892@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <benh@debian.org>,
	David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>,
	David Woodhouse <dwmw2@infradead.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110107215505.GA1892@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 7, 2011 at 1:55 PM, Francois Romieu <romieu@fr.zoreil.com> =
wrote:
> Linus Torvalds <torvalds@linux-foundation.org> :
> [...]
>> I just confirmed that building it as a module works
>
> I have just tried a non-modular build and it worked without firmware.
>
=2E..
> [ =A0 =A04.340876] sd 1:0:0:0: [sda] Attached SCSI disk
> [ =A0 63.968081] r8169 0000:02:00.0: eth0: unable to apply firmware p=
atch
>
> It's here. After a 60 seconds black-out.

Hmm. I never even waited for 60 seconds. Maybe my boot would have
continued after the delay.

                    Linus
