From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8] Phonet: set the pipe handle using setsockopt
Date: Fri, 18 Nov 2011 15:01:35 -0500 (EST)
Message-ID: <20111118.150135.2276513032114714090.davem@davemloft.net>
References: <1321615325-2025-1-git-send-email-hemant.ramdasi@stericsson.com>
	<2868814.BQAWhlMiRL@hector>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab1KRUBm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 15:01:42 -0500
In-Reply-To: <2868814.BQAWhlMiRL@hector>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Fri, 18 Nov 2011 13:41:56 +0200

> Le Vendredi 18 Novembre 2011 16:52:05 ext Hemant Vilas RAMDASI a =E9c=
rit :
>> From: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
>>=20
>> This provides flexibility to set the pipe handle
>> using setsockopt. The pipe can be enabled (if disabled) later
>> using ioctl.
>>=20
>> Signed-off-by: Hemant Ramdasi <hemant.ramdasi@stericsson.com>
>> Signed-off-by: Dinesh Kumar Sharma <dinesh.sharma@stericsson.com>
>=20
> Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
