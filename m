From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Sat, 20 Jun 2009 17:47:43 -0700
Message-ID: <43e72e890906201747qb409fa7ue1bc84272417e03@mail.gmail.com>
References: <20090615214735.GE23972@bombadil.infradead.org>
	<20090616021011.GF23972@bombadil.infradead.org> <20090616032034.GA17932@kroah.com>
	<20090616042113.GA5680@tesla> <20090616093401.GA11602@jm.kir.nu>
	<20090616181705.GB31506@tesla> <20090619150015.GC1389@ucw.cz>
	<43e72e890906191010v4b2e79a5x2c7b722b8209933c@mail.gmail.com>
	<20090619221909.GC2229@elf.ucw.cz> <alpine.LFD.2.01.0906191555390.16802@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	Luis Rodriguez <Luis.Rodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.01.0906191555390.16802-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 19, 2009 at 3:56 PM, Linus
Torvalds<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>
>
> On Sat, 20 Jun 2009, Pavel Machek wrote:
>>
>> Non-intrusive bugfixes _are_ welcome after -rc1.
>
> After -rc1, yes.
>
> After something like -rc5? No.
>
> They had better be _really_ important things, and _really_ obvious an=
d
> non-intrusive. =C2=A0Not just "any bug".

=46or the sake of documentation and to help developers better understan=
d
this it would be nice if we could be a little more clear here. I can
think of patches which may not be obvious but yet very important, for
example. Can we simply document that the patches must be important,
non-intrusive, and must have a very clear commit log entry of what it
is fixing. Judgment for the degree of importance of the patch can be
left up to the subsystem maintainer.

Is it reasonable to document this as I describe above?

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
