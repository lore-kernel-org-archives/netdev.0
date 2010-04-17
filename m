From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB - What's the minimal value for 'rate' parameter?
Date: Sat, 17 Apr 2010 23:01:52 +0200
Message-ID: <4BCA21C0.60709@gmail.com>
References: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>	<4BBE4BB4.1060209@gmail.com>	<i2k298f5c051004090840y7e47a53eqd17b0685088551ac@mail.gmail.com>	<20100409212657.GA3560@del.dom.local>	<p2q298f5c051004140322hc54f5315taa5c7d85cb74f06@mail.gmail.com>	<4BC63766.5080104@gmail.com> <m3bpdi8mhw.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:32800 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194Ab0DQVCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 17:02:00 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1056928fga.1
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 14:01:58 -0700 (PDT)
In-Reply-To: <m3bpdi8mhw.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benny Amorsen wrote, On 04/17/2010 11:19 AM:

> Jarek Poplawski <jarkao2@gmail.com> writes:
> 
>> As I wrote before, the minimal (overflow safe) rate depends on max
>> packet size, and for 1500 byte it would be something around:
>> 1500b/2min, so if your clients can wait so long, try this:
> 
> Wouldn't it be nice of either tc or the kernel to warn about wrong
> configurations, or possibly reject them completely?

...or have it documented etc.

Acked-by: Jarek P. ;-)
