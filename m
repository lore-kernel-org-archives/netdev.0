From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: enforce RX_MULTI_EN for the 8168f.
Date: Wed, 11 Sep 2013 16:16:06 -0400 (EDT)
Message-ID: <20130911.161606.1575635427616463157.davem@davemloft.net>
References: <20130907231535.GB24530@electric-eye.fr.zoreil.com>
	<522C391A.3020408@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	david@unsolicited.net, fredo@starox.org, hayeswang@realtek.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757188Ab3IKUQJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:16:09 -0400
In-Reply-To: <522C391A.3020408@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 08 Sep 2013 10:45:14 +0200

> On 09/08/2013 01:15 AM, Francois Romieu wrote:
>> Same narrative as eb2dc35d99028b698cdedba4f5522bc43e576bd2 ("r8169:
>> RxConfig
>> hack for the 8168evl.") regarding AMD IOMMU errors.
>>
>> RTL_GIGA_MAC_VER_36 - 8168f as well - has not been reported to behav=
e
>> the
>> same.
>>
>> Tested-by: David R <david@unsolicited.net>
>> Tested-by: Fr=E9d=E9ric Leroy <fredo@starox.org>
>> Cc: Hayes Wang <hayeswang@realtek.com>
>> ---
>=20
> Your signed-off-by is missing.

=46rancois, if you reply to this thread with your signoff, all will
be well and I will apply this.

Thanks.
