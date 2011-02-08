From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v4 0/5] net: Unified offload configuration
Date: Wed, 9 Feb 2011 00:55:43 +0100
Message-ID: <20110208235543.GA14251@rere.qmqm.pl>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl> <20110207.133721.48496023.davem@davemloft.net> <20110208.114018.71120939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35440 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab1BHXzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 18:55:46 -0500
Content-Disposition: inline
In-Reply-To: <20110208.114018.71120939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 08, 2011 at 11:40:18AM -0800, David Miller wrote:
> BTW, none of your patch postings from today made it to the mailing
> lists because there were syntax errors in your email headers.
>=20
> Therefore, you'll need to resend them.

Hmm, that's weird. My mailer said:

mail.info: Feb  8 15:23:59 postfix/smtp[6076]: 7138813909: to=3D<netdev=
@vger.kernel.org>, relay=3Dvger.kernel.org[209.132.180.67]:25, delay=3D=
3, delays=3D0.09/0.08/2.2/0.7, dsn=3D2.7.0, status=3Dsent (250 2.7.0 no=
thing apparently wrong in the message. BF:<H 0>; S1754489Ab1BHOX7)
mail.info: Feb  8 15:23:59 postfix/smtp[6110]: BA99413A5F: to=3D<netdev=
@vger.kernel.org>, relay=3Dvger.kernel.org[209.132.180.67]:25, delay=3D=
3, delays=3D0.2/0.45/1.5/0.84, dsn=3D2.7.1, status=3Dsent (250 2.7.1 Lo=
oks like Linux source DIFF email.. BF:<H 0>; S1754575Ab1BHOX7)
[same for other patches in series]

And I got no bounces. What were the errors?

Best Regards,
Micha=B3 Miros=B3aw
