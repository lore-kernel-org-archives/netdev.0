From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Fri, 13 Oct 2006 09:39:57 -0700
Message-ID: <452FC15D.7030902@hp.com>
References: <000101c6edd5$a880d430$1a04010a@V505CP> <452E69B2.4030306@hp.com>	<469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>	<452EC7B9.2030801@hp.com> <452F11E4.8050508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>,
	Martin Schiller <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:31404 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1751684AbWJMQkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 12:40:01 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <452F11E4.8050508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Rick Jones a =E9crit :
>=20
>>> More to the point, on what basis would the application be rejecting=
 a
>>> connection request based solely on the SYN?
>>
>>
>> True, it isn't like there would suddenly be any call user data as in=
=20
>> XTI/TLI.
>=20
>=20
> DATA payload could be included in the SYN packet. TCP specs allow thi=
s=20
> AFAIK.

Yes, but it isn't supposed to be delivered until the 3-way handshake is=
 complete=20
right?

rick jones
