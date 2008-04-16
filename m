From: "Sverre Rabbelier" <alturin@gmail.com>
Subject: Re: Reporting bugs and bisection
Date: Wed, 16 Apr 2008 21:43:47 +0200
Message-ID: <bd6139dc0804161243i5e5c973aia0cf2d5ec19079fa@mail.gmail.com>
References: <20080413205406.GA9190@2ka.mipt.ru> <20080414043939.GA6862@1wt.eu>
	 <20080414053943.GU9785@ZenIV.linux.org.uk>
	 <20080413232441.e216a02c.akpm@linux-foundation.org>
	 <20080414072328.GW9785@ZenIV.linux.org.uk>
	 <Xine.LNX.4.64.0804150131300.4160@us.intercode.com.au>
	 <4804765B.2070300@davidnewall.com>
	 <bd6139dc0804160515s64a36748v49556c56d475dda4@mail.gmail.com>
	 <20080416132634.GA545@cs181133002.pp.htv.fi>
	 <20080416120247.c665859c.akpm@linux-foundation.org>
Reply-To: sverre@rabbelier.nl
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@kernel.org>, git@vger.kernel.org,
	linux-kernel@vger.kernel.org, jmorris@namei.org,
	viro@zeniv.linux.org.uk, w@1wt.eu, david@lang.hm,
	sclark46@earthlink.net, johnpol@2ka.mipt.ru, rjw@sisk.pl,
	tilman@imap.cc, Valdis.Kletnieks@vt.edu, lkml@rtr.ca,
	davem@davemloft.net, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org, netdev@vger.kernel.org,
	davidn@davidnewall.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757376AbYDPToL@vger.kernel.org>
In-Reply-To: <20080416120247.c665859c.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2008 at 9:02 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>  Sounds like an interesting project.

Thank you :).

>  Well yes.  One outcome of the project would be to tell us what changes we'd
>  need to make to our processes to make such data gathering more effective.

I defenitly agree here, the command's reliability could be increased
by always specifying bugfixes in a certain way. 'fixed-bug:' for
example should be very recognizable.

>  Of course, we may not actually implement such changes.  That would depend
>  upon how useful the output is to us.

Ah yes, free will and whatnot. Then again, everybody already does
'signed-off-by:', if there's an easy command in git to mark a bugfix,
it would increase the odds of people using it. Perhaps something like
'git commit -b 10256" which would then automagically append a
predefined message to the commit users would feel more inclined?

Cheers,

Sverre Rabbelier
