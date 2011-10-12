From: Qunfang Zhang <qzhang@redhat.com>
Subject: Re: Host got crash when guest running netperf client with UDP_STREAM
 protocol with IPV6
Date: Wed, 12 Oct 2011 09:33:59 +0800
Message-ID: <4E94EE87.6070508@redhat.com>
References: <4E93A94A.1010001@redhat.com> <1318313091.2606.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858Ab1JLBfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 21:35:09 -0400
In-Reply-To: <1318313091.2606.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric
Sorry, just got that Jason has commited a patch for it. So, please=20
ignore my mail.  Thanks.

On 10/11/2011 02:04 PM, Eric Dumazet wrote:
> Le mardi 11 octobre 2011 =C3=A0 10:26 +0800, Qunfang Zhang a =C3=A9cr=
it :
>   =20
>> Hi, guys
>>
>> I found the following bug on RHEL6.2 kernel and after re-test, lates=
t
>> stable kernel also has this problem.
>> Jiri suggests it would be best to resolve this via upstream as well,
>> so I send you the mail.  Thank you.
>>
>> Bug 740465 - Host got crash when guest running netperf client with
>> UDP_STREAM protocol with IPV6
>> https://bugzilla.redhat.com/show_bug.cgi?id=3D740465
>>
>> For the vmcore log please also find it from the bug attachment.
>>
>>
>>
>>     =20
> Isnt it fixed by Jason Wang patch ?
>
> ( ipv6: fix NULL dereference in udp6_ufo_fragment() )
>
>
>
>
>   =20
