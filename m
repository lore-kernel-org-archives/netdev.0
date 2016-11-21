From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH net 1/1] net: batman-adv: Treat
	NET_XMIT_CN as transmit successfully
Date: Mon, 21 Nov 2016 09:31:04 +0100
Message-ID: <1807277.5c8tsCoh5a@bentobox>
References: <1479688779-1328-1-git-send-email-fgao@ikuai8.com>
 <1926952.1nDu9mPud9@bentobox>
 <CA+6hz4rZyacN_jg74JLg8EWkno2aJEnwJSTwRaw558uE-zAaxA@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1632388.DNzhomgMjo";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, a@unstable.cc,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Feng Gao <gfree.wind-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CA+6hz4rZyacN_jg74JLg8EWkno2aJEnwJSTwRaw558uE-zAaxA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

--nextPart1632388.DNzhomgMjo
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Montag, 21. November 2016 16:21:52 CET Feng Gao wrote:
> Hi Sven,
> 
> On Mon, Nov 21, 2016 at 4:16 PM, Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org> wrote:
> > On Montag, 21. November 2016 08:39:39 CET fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org wrote:
> >> From: Gao Feng <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>
> >>
> >> The tc could return NET_XMIT_CN as one congestion notification, but
> >> it does not mean the packe is lost. Other modules like ipvlan,
> >
> > s/packe/packet/
> 
> What's this mean?

That there is a minor typo (*t* is missing) and this sed statement (when
applied only to the commit message) would fix it.

David already marked this patch as "Under Review" in his patchwork. So I would
guess that he will accept this patch and not the batman-adv maintainers. And
maybe he will fix this small typo - or maybe not.

Kind regards,
	Sven
--nextPart1632388.DNzhomgMjo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYMrDIAAoJEF2HCgfBJntGkCoP/iLihrMfC5ifPWFVzSmuh8N0
f9f+HlAj+uWYQ8EagEWkvTMEIIE1is0TkuQzA9MjvmYSyqYsHM4qxYUqSlzkGIaQ
qxVlI6ZqhaezStOrLNj9+sP8KW7aZ4xLQKSt/sV6rXY3IUhqFY4F4dwZ1JWOAzM6
73z9iB7mYv9qjCdtvCccRNfeWonGapPlnqaXm+rS/J6angNd8xh3PngXLqEpOYsW
LLW6QfCLi+aYAWk5gCJwjtN8d87jkSNmRe6XUNwP0ZLF5uE5IJPGh+zMtJY+yibr
OlkksDMA8NPbkjgMHlheGexP8KgP53GjcSDukklC6hMm4eR7hMNoWvfAIXeUNHpM
OAaHMmKHC7Ii0fioPq5UWpM7yUZCdYVSImIatTHJsHKSWKmfkiggFoQ819b8axp/
NPay7+JlXm4NsAYwPPiUssidFz8NcqpWabY0XTwI+RfHbUqu2Cg8wf4t+3lbmMzk
kA+Bk93pbicAP6Z5o7dfRYbZUhsW/9ByZhvSFG7RsdFX1eGdTqz1j8Q3SkPlKG0X
n6c5f/xIOkgjdo7ySlrPaGpE4DaAHR4Q3HYLJSlQI74782t8d3hY1okeTk0wtRc+
onuR/LjkqwuSzAER4KuKJavrSRk5+APhTP/wCOrKCvmw7D2AI6opZWwznbj//RkW
1nx88TtceOKfvc3/9tC1
=dj3+
-----END PGP SIGNATURE-----

--nextPart1632388.DNzhomgMjo--
