From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Sat, 21 May 2011 16:42:46 -0700
Message-ID: <BANLkTim4q5dK6nOb=pVKbk1c8b-Nh_hBfA@mail.gmail.com>
References: <m11uzrvd26.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m11uzrvd26.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 21, 2011 at 4:39 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> In a hopeless quest to avoid conflicts when merging a new system call
> and wiring it up I have pulled in bits of net-next and the parisc tre=
e.
> You have already pulled the net-next bits. =A0The parisc bits in my t=
ree
> are:

Ok, this just means that I won't pull from you.

It's that simple. We don't do this. Ever.

Why the hell did you even worry about wiring up parisc system calls?
That's not your job.

                              Linus
