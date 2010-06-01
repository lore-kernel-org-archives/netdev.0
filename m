From: Richard Hartmann <richih.mailinglist@gmail.com>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
	multi-link
Date: Tue, 1 Jun 2010 13:28:59 +0200
Message-ID: <AANLkTinpsIs7qMSpQ78fWCTHh03iLBIwRlsU7sqJau08@mail.gmail.com>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
	<20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
	<4BACE827.4070006@gmail.com>
	<20100326170428.6c1ad66c@lxorguk.ukuu.org.uk>
	<4BB31E00.8060204@netservers.co.uk>
	<20100529021624.GA2538@brick.ozlabs.ibm.com>
	<AANLkTil7fk_ikrSPiZnqcJSLGCrzcCrCwbeuUMY5Yu5v@mail.gmail.com>
	<4C04ECA3.1080905@netservers.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Alexander E. Patrakov" <patrakov@gmail.com>,
	linux-kernel@vger.kernel.org
To: Ben McKeegan <ben@netservers.co.uk>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4C04ECA3.1080905@netservers.co.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 1, 2010 at 13:18, Ben McKeegan <ben@netservers.co.uk> wrote=
:

> This isn't really a bug fix. =C2=A0Its a behavioural change to work a=
round poor
> quality/mismatched underlying PPP channels.

Maybe not a bug in the Linux kernel itself, but certainly in the real w=
orld
that exists around Linux. Similar to how a change to a device driver th=
at
is needed to work around broken hardware is a bug fix, imo.


RIchard
