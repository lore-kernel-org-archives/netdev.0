From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups
Date: Tue, 28 Apr 2009 11:24:37 +0200
Message-ID: <49F6CB55.2010804@cosmosbay.com>
References: <49F3308B.1030507@cosmosbay.com>	<20090426.020411.157511269.davem@davemloft.net>	<49F43B8F.2050907@cosmosbay.com> <20090428.021550.187592488.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cl@linux.com, jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40815 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959AbZD1JZk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 05:25:40 -0400
In-Reply-To: <20090428.021550.187592488.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Sun, 26 Apr 2009 12:46:39 +0200
>=20
>> [PATCH] poll: Avoid extra wakeups in select/poll
>=20
> Looks great to me:
>=20
> Acked-by: David S. Miller <davem@davemloft.net>
>=20
> But this has to go through something other than the
> networking tree, of course :-)
>=20
>=20
Sure, I'll do that promptly :)

Thanks


