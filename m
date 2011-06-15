From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Wed, 15 Jun 2011 00:10:14 +0000
Message-ID: <157393863283F442885425D2C454285601D4D26B@nasanexd02a.na.qualcomm.com>
References: <cover.1308024069.git.joe@perches.com>
 <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>
 <BANLkTik8+OK3QNreHLn7rqx-s4UXNypOEg@mail.gmail.com>
 <1308061044.18987.14.camel@Joe-Laptop>
 <BANLkTimK4RXsQUnHbE0Eu9==54AbdBKzzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Cliburn <jcliburn@gmail.com>
To: Chris Snook <chris.snook@gmail.com>, Joe Perches <joe@perches.com>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:2167 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab1FOAKP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 20:10:15 -0400
In-Reply-To: <BANLkTimK4RXsQUnHbE0Eu9==54AbdBKzzQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris
     Yes, Jie yang doesn't maintain it any more. Could you add cjren@qc=
a.qualcomm.com to the list ? thanks.

-Xiong

-----Original Message-----
=46rom: Chris Snook [mailto:chris.snook@gmail.com]=20
Sent: Tuesday, June 14, 2011 22:23
To: Joe Perches; Huang, Xiong
Cc: netdev@vger.kernel.org; Jay Cliburn
Subject: Re: [PATCH net-next 2/2] drivers/net: Remove casts of void *

On Tue, Jun 14, 2011 at 10:17 AM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2011-06-14 at 06:34 -0400, Chris Snook wrote:
>> atlx looks fine.
>> Acked-By: Chris Snook <chris.snook@gmail.com>
>
> Hey Chris.
>
> I get bounce messages from one of the ATLX DRIVERS MAINTAINERS.
>
> ATLX ETHERNET DRIVERS
> M: =A0 =A0 =A0Jay Cliburn <jcliburn@gmail.com>
> M: =A0 =A0 =A0Chris Snook <chris.snook@gmail.com>
> M: =A0 =A0 =A0Jie Yang <jie.yang@atheros.com>
>
> Jie Yang at atheros.com doesn't work for me.
> Perhaps that entry should be removed?
>
> Jie Yang doesn't seem to have contributed any acks or patches to=20
> drivers/net/atlx/
>
> <jie.yang@atheros.com>: host gatewayhorse1.qualcomm.com[199.106.114.1=
11] said:
> =A0 =A0550 #5.1.0 Address rejected jie.yang@atheros.com (in reply to =
RCPT=20
> TO
> =A0 =A0command)

Xiong --

Is Jie still working on atlx drivers? Should someone else (such as
yourself) at Atheros be listed instead, or is this just a temporary ser=
ver error?

-- Chris
