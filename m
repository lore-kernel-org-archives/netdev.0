From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] Net-next: ipv4: typo issue, remove erroneous semicolon
Date: Tue, 23 Apr 2013 14:35:07 +0800
Message-ID: <51762B9B.2070008@asianux.com>
References: <517549F4.7030806@cogentembedded.com> <5175DFF9.4040000@asianux.com> <5175F5C3.8060503@asianux.com> <20130423.011604.1061769362231812796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sergei.shtylyov@cogentembedded.com, pshelar@nicira.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:29630 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933Ab3DWGfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 02:35:54 -0400
In-Reply-To: <20130423.011604.1061769362231812796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8823=E6=97=A5 13:16, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Tue, 23 Apr 2013 10:45:23 +0800
>=20
>> > need remove erroneous semicolon, which is found by EXTRA_CFLAGS=3D=
-W.
>> > the related commit number: c54419321455631079c7d6e60bc732dd0c5914c=
5
>> > (by Pravin B Shelar <pshelar@nicira.com>  Mon Mar 25 14:49:35 2013=
)
>> >=20
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Do not put the destination GIT tree outside of the "[]" brackets.  Pu=
t
> it inside the "[]" brackets, so it doesn't show up in the final commi=
t
> message.
>=20
  ok, thanks.

> Also, do not capitalize it, just "net-next" is fine.
>=20
  ok, thanks.

> Putting "(by Pravin B Shelar <pshelar@nicira.com>  Mon Mar 25 14:49:3=
5 2013)"
> is not what we asked for, we asked for the commit message header line
> which for this commit would be ("GRE: Refactor GRE tunneling code.")
>=20
  ok, thanks.

> I want to know by what example you are doing these things?  Follow
> the model of other successful patch submitters, such as Eric Dumazet,
> Ben Hutchings, Thomas Graf, Simon Horman, etc. just to name a few.
>=20
> Do exactly what they do, because I never have to tell those people ho=
w
> to properly format their commit messages, header lines, and the patch
> itself.
>=20
  ok, thanks.

> In your commit message body, properly capitalize your sentences.
>=20
  ok, thanks.

> This feedback applies to all of the patches you have submitted.  I'm
> sorry I have to pick you apart so much, but if you're going to
> contribute regularly you have to get this right, I can't be constantl=
y
> fixing up by hand every patch you submit.
>=20
>=20
  ok, thanks.

  need I send patch v3 ?


--=20
Chen Gang

Asianux Corporation
