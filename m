From: "Jesper Juhl" <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Don't needlessly initialize variable to NULL in zd_chip (was: Re: [PATCH 13/30] net: Don't do pointless kmalloc return value casts in zd1211 driver)
Date: Fri, 31 Aug 2007 01:04:09 +0200
Message-ID: <9a8748490708301604k688daad8p145fb9106b442d91@mail.gmail.com>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
	 <9a8748490708301320o49d8e794vc5c37ffc938006f1@mail.gmail.com>
	 <1188512393.6062.156.camel@localhost>
	 <200708310030.31713.jesper.juhl@gmail.com>
	 <20070830154255.6a146c21.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Joe Perches" <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, "Daniel Drake" <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	"Linux Kernel Mailing List" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Ulrich Kunitz" <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Randy Dunlap" <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070830154255.6a146c21.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 31/08/2007, Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
...
>
> BTW:  http://marc.info/?l=linux-wireless&m=118831813500769&w=2
>
...

Heh, thanks Randy.

All too often patches get missed since I don't happen to include the
right magic person to Cc. So I generally take a "better to have one Cc
too many than miss one" approach when sending patches - otherwise I
just end up resending it several times and eventually have to bother
Andrew to move it through -mm.

I see the point of people not getting things twice, but too many
patches slip through the cracks already (and not just my patches,
that's a general problem) so I'd rather inconvenience a few people
with one extra email than missing the proper maintainer by not Cc'ing
the right list.    Picking the right list/set of people to Cc is hard!


(whoops, mistakenly didn't do a reply-to-all initially; sorry Randy,
now you'll get this mail twice ;)


--
Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
