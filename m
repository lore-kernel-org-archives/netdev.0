From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix raw socket checksum for udplite
Date: Wed, 27 Mar 2013 00:55:14 -0400 (EDT)
Message-ID: <20130327.005514.1091004361831592240.davem@davemloft.net>
References: <1364337095-19663-1-git-send-email-zenczykowski@gmail.com>
	<515259C1.20204@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zenczykowski@gmail.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com, mwdalton@google.com
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754322Ab3C0EzP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 00:55:15 -0400
In-Reply-To: <515259C1.20204@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Brian Haley <brian.haley@hp.com>
Date: Tue, 26 Mar 2013 22:30:25 -0400

> On 03/26/2013 06:31 PM, Maciej =AFenczykowski wrote:
>> From: Maciej =AFenczykowski <maze@google.com>
>>=20
>> Commit d3a1be9cba86 from Brian Haley in Nov 2006
>> "[IPv6]: Only modify checksum for UDP" forgot about
>> UDPLITE.
>=20
> I'm not sure I'd say I "forgot about" it, UDPLITE support didn't exis=
t in Linux
> until three+ weeks after that commit.

Maciej, please fix the commit message to not blame that commit, and
resubmit, thanks.
