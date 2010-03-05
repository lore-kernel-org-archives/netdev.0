From: "Figo.zhang" <figo1802@gmail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Fri, 05 Mar 2010 21:52:17 +0800
Message-ID: <1267797137.2576.11.camel@myhost>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	 <4B8D1C02.1010204@softplc.com>
	 <c6ed1ac51003021746n2b246591g880b584550ec5e84@mail.gmail.com>
	 <f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	 <c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	 <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:39715 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455Ab0CENwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 08:52:25 -0500
Received: by pvb32 with SMTP id 32so726583pvb.19
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 05:52:24 -0800 (PST)
In-Reply-To: <f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> and even if the fourth test succeeds, if I then send a file from other
> host the next ping or any other communication fails. I just tried to
> make some SSH sessions. It goes without a problem till I issue a ping
> after that.
> 
> If I test the system with nuttcp I have no problem.
the network driver seems work well for system. the "netcat" application
is build in busybox? you can check busybox configure. 
> 
> Do you have any idea how to debug this? If I remove the NAPI support I
> have no problem with the same kernel and environment. I'd really like
> to get the whole stuff working.
> 
> Regards,
> Yegor


