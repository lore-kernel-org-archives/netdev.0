From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Thu, 12 May 2011 12:17:00 -0700
Message-ID: <BANLkTimuSNHm_-tPV2EQZp6acDsei9f2Mw@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com>
 <BANLkTi=YDZa+BRaG90vJsjrT9VxgySrDRQ@mail.gmail.com> <4DCC2CFD.4010807@kdbg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Lutomirski <luto@mit.edu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, git@vger.kernel.org
To: Johannes Sixt <j6t@kdbg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DCC2CFD.4010807@kdbg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2011 at 11:54 AM, Johannes Sixt <j6t@kdbg.org> wrote:
>
> Except that you should git reset --hard; git bisect reset gets you out
> of bisect-mode, no?

Yeah, sorry, my bad.

                Linus
