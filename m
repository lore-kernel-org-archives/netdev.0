From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH 02/14 v2] mac802154: allocation of ieee802154 device
Date: Thu, 5 Jan 2012 18:11:54 +0400
Message-ID: <CAJmB2rCED2whi1o=dPyi15ZaoTw9o5RcSokeZuWtwPNVGf9mMQ@mail.gmail.com>
References: <1324919047-14851-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<20111226.150924.734645949941473044.davem@davemloft.net>
	<CAJmB2rAyyPmYTmtTvFK3UuFn9t+361raA5R=92XPNHrH7dfgfw@mail.gmail.com>
	<20111228.023145.2078199792492848729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:60878 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757334Ab2AEOL4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 09:11:56 -0500
Received: by lahd3 with SMTP id d3so176897lah.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 06:11:55 -0800 (PST)
In-Reply-To: <20111228.023145.2078199792492848729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

2011/12/28 David Miller <davem@davemloft.net>:
> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> Date: Wed, 28 Dec 2011 10:19:23 +0300
>
>> Dear David,
>>
>> 2011/12/26 David Miller <davem@davemloft.net>:
>>> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
>>> Date: Mon, 26 Dec 2011 20:04:07 +0300
>>>
>>>> + =A0 =A0 /*
>>>> + =A0 =A0 =A0* SoftMAC device is registered and running. One can a=
dd
>>>> + =A0 =A0 =A0* subinterfaces.
>>>> + =A0 =A0 =A0*/
>>>> + =A0 =A0 unsigned running:1;
>>>
>>> I told you to change this to a 'bool' in my previous review of your=
 changes.
>>>
>>> I'm pretty much going to stop reviewing right here, because I don't
>>> want to waste my time only to find out that you've ignored other
>>> review feedback I've already given to you.
>>>
>>
>> Regarding your comments to my previous post, none of them was omitte=
d. I
>> reworked code according to them and added extended comments in a pat=
ch
>> explaining why I can't follow your hint. The issue with 'bool' you m=
arked
>> was in another patch (#14) which I already fixed.
>
> My bad, I thought I had asked you do it here too.
>
> Sorry about that.

Should I wait for the review of remaining patches or it would be
better to resubmit all the series with changes according to your new
comments?

With best regards,
Alexander
