From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 action/policer question
Date: Mon, 15 Jun 2009 18:37:06 +0200
Message-ID: <20090615163706.GA9469@ami.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com> <20090615145222.GA2767@ami.dom.local> <4A367255.5050604@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:48890 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760465AbZFOQh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 12:37:26 -0400
Received: by fxm7 with SMTP id 7so34257fxm.37
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 09:37:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A367255.5050604@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 06:09:57PM +0200, Pawe=B3 Staszewski wrote:
> Jarek Poplawski pisze:
>> On Mon, Jun 15, 2009 at 09:32:08AM -0400, jamal wrote:
>>  =20
>>> On Mon, 2009-06-15 at 11:19 +0000, Jarek Poplawski wrote:
>>>
>>>    =20
>>>>> This is only a sample but is not working
>>>>>        =20
>>> It does seem to be working!
>>> How did you reach conclusion it wasnt working?
>>>
>>>    =20
>>>>>         Action statistics:
>>>>>         Sent 42351 bytes 110 pkt (dropped 0, overlimits 32 requeu=
es 0)
>>>>>         rate 0bit 0pps backlog 0b 0p requeues 0
>>>>>        =20
>>> 32 packets hit the policer - double check your parameters please to=
 make
>>> sure they are correct.
>>>    =20
>>
>>  =20
> Yes. packets hits policer but second action dont drop packets.

I guess Jamal meant 'hit the policer' =3D=3D 'dropped' (and 110 - 32
passed). So the question is how did you checked it's otherwise.

Jarek P.
