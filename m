From: Lukas Hejtmanek <xhejtman@hell.sks3.muni.cz>
Subject: Re: 2.6.9-rc2-mm2 fn_hash_insert oops
Date: Thu, 23 Sep 2004 16:02:28 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040923140228.GA16675@mail.muni.cz>
References: <20040923103723.GA12145@mail.muni.cz> <E1CARaS-00071j-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268474AbUIWOFb@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CARaS-00071j-00@gondolin.me.apana.org.au>
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2004 at 09:16:32PM +1000, Herbert Xu wrote:
> Lukas Hejtmanek <xhejtman@mail.muni.cz> wrote:
> >=20
> > However there is still the issue with endless loop in fn_hash_delet=
e :(
>=20
> Same problem, same fix.  Can someone think of a generic fix to
> list_for_each_*?

It helped. Thankx.

--=20
Luk=E1=B9 Hejtm=E1nek
