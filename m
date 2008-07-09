From: Alexandre Oliva <oliva@lsd.ic.unicamp.br>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Wed, 09 Jul 2008 17:43:54 -0300
Message-ID: <orzloq6b5h.fsf@oliva.athome.lsd.ic.unicamp.br>
References: <486CC440.9030909@garzik.org>
	<Pine.LNX.4.64.0807031353030.11033@blonde.site>
	<486CCFED.7010308@garzik.org>
	<20080703.133428.22854563.davem@davemloft.net>
	<1215118476.10393.692.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756114AbYGIUps@vger.kernel.org>
In-Reply-To: <1215118476.10393.692.camel@pmac.infradead.org> (David Woodhouse's message of "Thu\, 03 Jul 2008 21\:54\:36 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jul  3, 2008, David Woodhouse <dwmw2@infradead.org> wrote:

> Now, can someone _please_ give me a straight response to the allegati=
on
> that the TSO firmware on the tg3 is _optional_ anyway, and that it ca=
n
> work without it?

=46TR, I got two reports from BLAG users, through Jeff Moe, that
tg3 worked fine with linux-libre, in spite of the complete absence of
tg3 firmware in there.

I don't have any specific details about the tg3 hardware in question.

--=20
Alexandre Oliva         http://www.lsd.ic.unicamp.br/~oliva/
=46ree Software Evangelist  oliva@{lsd.ic.unicamp.br, gnu.org}
=46SFLA Board Member       =C2=A1S=C3=A9 Libre! =3D> http://www.fsfla.o=
rg/
Red Hat Compiler Engineer   aoliva@{redhat.com, gcc.gnu.org}
