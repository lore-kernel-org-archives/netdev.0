From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Linux Route Cache performance tests
Date: Mon, 07 Nov 2011 23:12:14 +0100
Message-ID: <4EB857BE.8010209@itcare.pl>
References: <4EB6AE62.5050803@itcare.pl>  <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>  <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>  <1320608290.6506.33.camel@edumazet-laptop> <4EB6ED2E.1070106@itcare.pl>  <1320614788.6506.38.camel@edumazet-laptop> <4EB702D3.1090703@itcare.pl>  <1320620915.6506.44.camel@edumazet-laptop> <4EB798A5.7000900@itcare.pl>  <1320656922.2361.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1320657385.2361.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:49460 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041Ab1KGWMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 17:12:18 -0500
In-Reply-To: <1320657385.2361.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2011-11-07 10:16, Eric Dumazet pisze:
> Le lundi 07 novembre 2011 =C3=A0 10:08 +0100, Eric Dumazet a =C3=A9cr=
it :
>
>> Obviously, cache removal will be possible only when performance with=
out
>> it is the same.
>>
>> Work is in progress, it started a long time ago.
>>
> One of the reason to get rid of this cache is its memory use.
>
> 256 bytes per entry, thats a lot of memory if you need 2.000.000
> entries...
>
Yes it is allot for embedded small systems
But in this times when many systems have 12 / 24 / 48GB of memory  - it=
=20
is not too much.



>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
