From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_nat_snmp: fix checksum calculation (v3)
Date: Thu, 30 Sep 2010 13:03:58 +0200
Message-ID: <4CA46E9E.40305@trash.net>
References: <AANLkTi=FbjWdAVfmoBK8E21gDEqxYyDsUyoJsGAfRumW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: =?UTF-8?B?546L6Z+s?= <clark.weeker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46270 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab0I3LEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 07:04:00 -0400
In-Reply-To: <AANLkTi=FbjWdAVfmoBK8E21gDEqxYyDsUyoJsGAfRumW@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.09.2010 10:25, =E7=8E=8B=E9=9F=AC wrote:
> Dear Patrick
>=20
>                   I am Clark Wang.  I have one question is that which
> version of kernel will contain this patch.

Its currently contained in the net-2.6.git tree, so it should be
in final .36 release.
