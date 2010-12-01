From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: check for assigned mac before adopting the
 slaves mac address
Date: Wed, 01 Dec 2010 10:45:46 -0800 (PST)
Message-ID: <20101201.104546.39187178.davem@davemloft.net>
References: <AANLkTi=-DzUmopboX13V_cd=mZnmD=mBNNCuhQYF0PQQ@mail.gmail.com>
	<8879.1290741991@death>
	<AANLkTi=+jMkrgNjVQvOOn_zURiJ4rXu5LL9eA4o0T9db@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dpstrand@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753052Ab0LASpT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 13:45:19 -0500
In-Reply-To: <AANLkTi=+jMkrgNjVQvOOn_zURiJ4rXu5LL9eA4o0T9db@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Strand <dpstrand@gmail.com>
Date: Wed, 1 Dec 2010 10:25:19 -0800

> On Thu, Nov 25, 2010 at 7:26 PM, Jay Vosburgh <fubar@us.ibm.com> wrot=
e:
>>
>> =A0 =A0 =A0 =A0Ok, fair enough. =A0If we want to get back to the ori=
ginal
>> behavior, however, your patch should only test for zero MAC address
>> instead of testing for zero MAC address in addition to first slave.
>>
>> =A0 =A0 =A0 =A0-J
>>
>> ---
>> =A0 =A0 =A0 =A0-Jay Vosburgh, IBM Linux Technology Center, fubar@us.=
ibm.com
>>
>=20
> Understood, that makes sense. The updated patch is below.

You need to provide a fresh posting of your patch, with a full
commit messag and proper Subject: line, as well as a proper
"Signed-off-by: " tag.

See Documentation/SubmittingPatches
