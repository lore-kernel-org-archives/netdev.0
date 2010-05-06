From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
Subject: Re: RTL-8110SC lockup with r8169
Date: Thu, 06 May 2010 13:00:54 +0100
Message-ID: <4BE2AF76.3020404@draigBrady.com>
References: <4BE1973D.8080502@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, Glen Gray <glen@lincor.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.slb.deg.dub.stisp.net ([84.203.253.98]:18588 "HELO
	mail1.slb.deg.dub.stisp.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755498Ab0EFMCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 08:02:09 -0400
In-Reply-To: <4BE1973D.8080502@draigBrady.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/10 17:05, P=C3=A1draig Brady wrote:
> Hi,
>=20
> We're having an issue with the r8169 driver, where very often
> (1 in 10 boots) it will lockup and our netboot system will hang.
> On this hardware previously, we used FC5 with the r1000 driver withou=
t issue.

I should have clarified that the lockup is at boot
when trying to bring up the interface.

I've now tried the Realtek r8169-6.013.00.tar.bz2 driver
dated April 28 2010, and it does _not_ have the issue.

cheers,
P=C3=A1draig.
