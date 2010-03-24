From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Wed, 24 Mar 2010 06:42:04 +0100
Message-ID: <1269409324.2915.44.camel@edumazet-laptop>
References: <1269377667.2915.25.camel@edumazet-laptop>
	 <20100323.144512.140757007.davem@davemloft.net>
	 <80769D7B14936844A23C0C43D9FBCF0F254E49AC69@orsmsx501.amr.corp.intel.com>
	 <20100323.195855.00471034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:34438 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059Ab0CXFmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 01:42:11 -0400
Received: by bwz1 with SMTP id 1so2549089bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 22:42:09 -0700 (PDT)
In-Reply-To: <20100323.195855.00471034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 19:58 -0700, David Miller a =C3=A9crit :
> From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
> Date: Tue, 23 Mar 2010 15:08:12 -0700
>=20
> > I'll do some digging on this to see what I can find out.
>=20
> Please see:  http://vger.kernel.org/jamal_netconf2006.sxi
> --

Thanks David, this is very informative !

Do we have a list of such network related documents ?


