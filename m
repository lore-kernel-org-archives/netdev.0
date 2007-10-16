From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCH 0/2] Interface groups
Date: Tue, 16 Oct 2007 11:47:44 +0200
Message-ID: <471488C0.4010003@balabit.hu>
References: <1192521703479-git-send-email-panther@balabit.hu> <47147B49.706@snapgear.com>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:56947 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758214AbXJPJrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 05:47:48 -0400
In-Reply-To: <47147B49.706@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philip Craig =EDrta:
> Laszlo Attila Toth wrote:
>> Hello,
>>
>> Different network interfaces can be grouped using the same group ID.=
 With this
>> patch fewer netfilter rules are necessary but it may also be used by=
 routing.
>=20
> This allows an interface to belong to only one group.  I expect there=
 are
> situations where you want more.  eg you might want a group of all ppt=
p
> connections, and another group of pptp connections for a subset of us=
ers.

With masked values it should work with only one group.

--=20
Attila
