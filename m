From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] qmi_wwan changes intended for 3.7
Date: Fri, 07 Sep 2012 14:50:34 -0400 (EDT)
Message-ID: <20120907.145034.1344376502528011934.davem@davemloft.net>
References: <1347039367-12399-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab2IGSug convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 14:50:36 -0400
In-Reply-To: <1347039367-12399-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri,  7 Sep 2012 19:36:05 +0200

> Just a couple of minor improvements for 3.7.  The QMI
> message size issue is not considered important enough for
> stable.  It does not affect the primary device function
> at all, and I consider it more of a feature enhancement
> than a fix.
>=20
>=20
> Bj=F8rn Mork (2):
>   net: qmi_wwan: increase max QMI message size to 4096
>   net: qmi_wwan: use a single bind function for all device types

Both applied, thanks.
