From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v3] net: mac802154: comparision issue of type cast, finding
 by EXTRA_CFLAGS=-W
Date: Thu, 25 Apr 2013 17:09:02 +0800
Message-ID: <5178F2AE.8020904@asianux.com>
References: <51766F74.2090007@asianux.com> <20130425.041044.768895561908042668.davem@davemloft.net> <5178ECA2.6020402@asianux.com> <20130425.050110.1637872699710810114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:43977 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263Ab3DYJJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 05:09:49 -0400
In-Reply-To: <20130425.050110.1637872699710810114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8825=E6=97=A5 17:01, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Thu, 25 Apr 2013 16:43:14 +0800
>=20
>> > (the change is for net/mac802154/mac802154.h, and exist in v3.9-rc=
8)
> It exist, but your patch doesn't apply cleanly there, it only applies
> cleanly to the -next tree, because other changes have happend to that
> file in -next.
>=20
>=20

OK, thanks. I will send patch v4 (still use the current subject and
comments)

--=20
Chen Gang

Asianux Corporation
