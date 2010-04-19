From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Mon, 19 Apr 2010 22:32:01 +0200
Message-ID: <1271709121.3845.94.camel@edumazet-laptop>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:64081 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761Ab0DSUch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 16:32:37 -0400
Received: by bwz19 with SMTP id 19so396bwz.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 13:32:35 -0700 (PDT)
In-Reply-To: <20100419.132318.192086187.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 avril 2010 =C3=A0 13:23 -0700, David Miller a =C3=A9crit :
> From: David Miller <davem@davemloft.net>
> Date: Mon, 19 Apr 2010 13:09:05 -0700 (PDT)
>=20
> > net-next-2.6 + Eric's port hashing patch, rps_cpus=3D"ffffffff,ffff=
ffff,ffffffff,ffffffff"
> >=20
> > tbench 64: Throughput 1593.13 MB/sec 64 procs
> > tbench 128: Throughput 2367.27 MB/sec 128 procs
>=20
> Eric, I think there is agreement that your patch is not a bad idea.
>=20
> Your original posting had whitespace damange in the patch plus I want
> to see a proper commit message and signoff, so could you please submi=
t
> this formally?

Hmm, this was not a formal patch, just an information.

Problem is if hardware provides rxhash, will it be "consistent" too ?



