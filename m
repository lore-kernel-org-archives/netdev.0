From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] link_gre6: really support encaplimit option
Date: Thu, 15 Jun 2017 08:33:38 -0700
Message-ID: <20170615083338.58ab73e6@xeon-e3>
References: <1497458742-6068-1-git-send-email-nicolas.dichtel@6wind.com>
        <20170614133118.482b3c59@xeon-e3>
        <012103d8-0ba0-10ea-1a5a-ef72871bc293@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35812 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdFOPdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 11:33:55 -0400
Received: by mail-pg0-f53.google.com with SMTP id k71so8172582pgd.2
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 08:33:50 -0700 (PDT)
In-Reply-To: <012103d8-0ba0-10ea-1a5a-ef72871bc293@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Jun 2017 09:28:46 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Le 14/06/2017 =C3=A0 22:31, Stephen Hemminger a =C3=A9crit :
> > On Wed, 14 Jun 2017 18:45:42 +0200
> > Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> >  =20
> >> This option is documented in gre6 help, but was not supported.
> >>
> >> Fixes: af89576d7a8c ("iproute2: GRE over IPv6 tunnel support.")
> >> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com> =20
> >=20
> > Sure applied.
> >  =20
> Thank you. It seems that your iproute2 tree on kernel.org is not up to da=
te, the
> last patch has been pushed one week ago.
>=20

Updated. Wanted to put in extended ack support but holding off until
for a good test case.
