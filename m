From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: pull request: batman-adv 20160518
Date: Wed, 18 May 2016 10:00:59 +0200
Message-ID: <26137034.Uc8ydxEavy@bentobox>
References: <1463547892-11290-1-git-send-email-a@unstable.cc>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart6809310.UBp0Ol2h88";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Antonio Quartulli <a@unstable.cc>,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1463547892-11290-1-git-send-email-a-2CpIooy/SPIKlTDg6p0iyA@public.gmane.org>
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

--nextPart6809310.UBp0Ol2h88
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Wednesday 18 May 2016 13:04:44 Antonio Quartulli wrote:
> I also have a question: I have another bugfix that should only be
> applied to 4.6 and not to 4.7/net-next - should I directly send it
> to stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org ?

Allow me to give some background info:

The bug was (accidentally) fixed by a refactoring patch [1] in net-next. But
the problem was then discovered by people which used net and not net-next.

I have created a bugfix [2] which would solve the problem in net but wouldn't
apply in net-next. This is why Antonio asked if he should send it to stable@
or if there is a better way to get it integrated.

Kind regards,
	Sven


[1] https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/net/batman-adv?id=efcc9d3069c982786f380bca8480a1aa2fd2721d
[2] https://git.open-mesh.org/linux-merge.git/commit/af06cf325cfb5a2685a6f8997585b83a91f36c4c

--nextPart6809310.UBp0Ol2h88
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXPCE7AAoJEF2HCgfBJntGAscQALpbJNgY2xACtcEm6JAF/Dfe
hzmPlkPlay5igog7SuAjCPu3TivFqsbVfDahZZB+ilED6jwPO6eJiLUJmTRS/0to
dhJOPO9cEAr50Q4Y95g846frHIlujpREnoQiC/i42oYn10n8qISSd03Vfsf77KWv
6LhTQzKuJkYbvfZBDskM7vySTJwJkv3nLtke/tAHDIZcs/XCto9WoMqNTSTHITgw
uxBUxfOvZnZhEN8HQgjTg3FzvrUj72EOHm9KBtU1TQXnkTTSJrVxH9MAkS/sN/VP
PfctmbuHexNAJelKYDf1GxtpYfAq3ShyRMC6XEojKInfiamvStJXZVAT5Zx4Uue4
aKqFCU3k2yrlCF5BjL9ayUJIFjEP9iPjlinJgpDC9OBZbF41X6Y46D4GEK85aOff
7TxgFlbt+Zk1mWlQSwGNWVDfY3J21YLTM1IL3QCHDDzYJ2Jj+BjAbfjmtc8I0Ogq
6zLT5vVeQMRecOKjpDTeIIN+HHUMUyiVUu7NkoCS9s1WbZt0OvxCO5OMPYfXqsxB
Kqv3g6mU9U2LMbbcSrbBD7ULRI+Ic8jeT6V7acQGcG9JqMnJE6DvGn55WwS6GaRs
V2LlapLNmZUM+0u1BzJ6NkP9LeLq8m7+BRdWxs3Mg872/cVJ9nyjvAOKPA8Ag2CR
dfC8+GR9blvdnZbZUC3l
=s6eu
-----END PGP SIGNATURE-----

--nextPart6809310.UBp0Ol2h88--
