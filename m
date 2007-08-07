From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2: workaround for lost IRQ and 2.6.22-stable
Date: Tue, 7 Aug 2007 15:14:39 -0400
Message-ID: <20070807151439.4fb7e06a@oldman>
References: <Pine.LNX.4.64.0708072043340.16599@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@kernel.org, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42397 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751452AbXHGTOl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 15:14:41 -0400
In-Reply-To: <Pine.LNX.4.64.0708072043340.16599@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Aug 2007 20:46:31 +0200 (CEST)
Krzysztof Oledzki <olel@ans.pl> wrote:

> Hello,
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.21.y.git=
;a=3Dcommitdiff;h=3Dfe1fe7c982f86624c692644e8ed05e132f4753cc
>=20
> Is this fix going to be included in the next 2.6.22-stable release or=
 is=20
> it not needed any more?
>=20
> Best regards,
>=20
>  				Krzysztof Ol=C4=99dzki

It stops the major hang from IRQ loss. 2.6.23 has more minor stuff that
probably aren't needed for stablilty
