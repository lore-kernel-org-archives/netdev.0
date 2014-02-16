From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v5 00/10] Support for the Broadcom GENET driver
Date: Sun, 16 Feb 2014 10:34:16 -0800
Message-ID: <12896228.bQPud9hHaP@lenovo>
References: <1392336531-28875-1-git-send-email-f.fainelli@gmail.com> <52FDC094.1020104@gmail.com> <20140214091943.GB3906@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, cernekee@gmail.com,
	mark.rutland@arm.com, romieu@fr.zoreil.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:38281 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200AbaBPSeU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 13:34:20 -0500
In-Reply-To: <20140214091943.GB3906@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 f=E9vrier 2014, 10:19:43 Richard Cochran a =E9crit :
> On Thu, Feb 13, 2014 at 11:07:00PM -0800, Florian Fainelli wrote:
> > Le 13/02/2014 21:29, David Miller a =E9crit :
> > >Series applied, thanks.
> >=20
> > Great, thanks David!
>=20
> Sorry for the late comment, but how about adding a call to
> skb_tx_timestamp(), in order to support so_timestamping?

The MAC itself is capable of providing a HW timestamp, I will look into=
 this a=20
little later.

Thanks!
--=20
=46lorian
