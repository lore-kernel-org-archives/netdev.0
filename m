From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project tree
Date: Wed, 4 Nov 2009 12:33:52 +1100
Message-ID: <646765f40911031733u1641c0dr5d4eec30031e7cea@mail.gmail.com>
References: <200911031951.05235.bzolnier@gmail.com> <200911032334.40547.bzolnier@gmail.com>
	<14add3d10911031509l328e7674kb625b70250ff30fb@mail.gmail.com>
	<200911040046.54247.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>,
	Luis Correia <luis.f.correia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200911040046.54247.bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 4, 2009 at 10:46, Bartlomiej Zolnierkiewicz
<bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> If you just want to continue with a hostile take-over of the rt2800
>> maintainership, then please
>> let us know that, so that we stop spending time on useless
>
> I fail to see why you see it as a hostile takeover.

Updating MAINTAINERS to replace the current developers with yourself
can be considered to be a hostile act.

If you want this for your own personal tree, then keep the patch
private - don't include it in pull requests, patch listings etc.

And if you genuinely want the maintainership of the rt28xx drivers,
then updating MAINTAINERS should be done as an afterthought after
clearly proving that you are capable of maintaining the driver and
working with the maintainers of the rt2x00 and wireless subsystems.

> I will be glad to cooperate with you or anyone else from rt2x00 project.
> However I will not spin in some stupid bureaucracy when I see that things
> can be done more effectively.

It's not "stupid bureaucracy" it's *how* *it's* *done*.

If I was going to submit a patch to the Marvell TOPDOG driver to add
support for another related chipset, I'd be going out of my way to
make sure that *everyone* involved was 100% happy so that the patch
can get out to the people who matter: the users.

Everyone has to do this, from big corporations like Intel, to you and
me. For example, I recall the Intel IWL developers being smacked down
a few months ago by John and David over exactly what constitutes a
post-merge window "bugfix".

The rules apply to everyone, just because you don't like them doesn't
mean you can ignore them.

Thanks,

-- 

Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
.Plan: http://sites.google.com/site/juliancalaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
