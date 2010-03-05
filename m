From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Fri, 5 Mar 2010 16:03:10 +0100
Message-ID: <f69abfc31003050703r36d0c91dy72fcec7950e88403@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	 <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
	 <1267797137.2576.11.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: "Figo.zhang" <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f212.google.com ([209.85.219.212]:53122 "EHLO
	mail-ew0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab0CEPDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 10:03:12 -0500
Received: by ewy4 with SMTP id 4so2487534ewy.28
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 07:03:11 -0800 (PST)
In-Reply-To: <1267797137.2576.11.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 5, 2010 at 2:52 PM, Figo.zhang <figo1802@gmail.com> wrote:
>
>>
>> and even if the fourth test succeeds, if I then send a file from other
>> host the next ping or any other communication fails. I just tried to
>> make some SSH sessions. It goes without a problem till I issue a ping
>> after that.
>>
>> If I test the system with nuttcp I have no problem.
> the network driver seems work well for system. the "netcat" application
> is build in busybox? you can check busybox configure.

I'm using Debian for ARM. So it is standard netcat for Debian 5.0.
