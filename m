From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Status update on Sun Neptune 10Gbit fibre using the NIU-driver.
Date: Sun, 22 Mar 2009 20:18:51 +0100
Message-ID: <49C68F1B.4000409@cosmosbay.com>
References: <49C600CE.70704@krogh.cc> <49C65AFC.3080300@cosmosbay.com> <49C67CF4.5080202@krogh.cc> <49C680A4.5020706@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44237 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbZCVTS5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 15:18:57 -0400
In-Reply-To: <49C680A4.5020706@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh a =E9crit :
> Jesper Krogh wrote:
>> Eric Dumazet wrote:
>>> Also, testing 2.6.29 could be interesting, since UDP receive
>>> path doesnt need to use a global rwlock anymore.
>>
>> ... That gained yet another 100MB/s.. now peaking out around
>> 1050-1060MB/s.
>=20
> Am I wrong thinking that theoretical max should be around 1150-1200MB=
/s ?
>=20

I dont know, what would be the current bottleneck ?

