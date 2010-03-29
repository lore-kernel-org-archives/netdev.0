From: Ben Hoyt <benhoyt@gmail.com>
Subject: Re: CVE-2009-4537
Date: Mon, 29 Mar 2010 14:27:06 +1300
Message-ID: <7c93bf1e1003281827x7565b0bds1c18d23d1607540e@mail.gmail.com>
References: <20100327142100.38d21565.michael.s.gilbert@gmail.com>
	 <20100327.103407.260084965.davem@davemloft.net>
	 <20100327.103600.246539458.davem@davemloft.net>
	 <20100329005046.GA2157@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:47910 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460Ab0C2B1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 21:27:07 -0400
Received: by pwi5 with SMTP id 5so6224921pwi.19
        for <netdev@vger.kernel.org>; Sun, 28 Mar 2010 18:27:07 -0700 (PDT)
In-Reply-To: <20100329005046.GA2157@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev,

We're working on some TCP networking stuff where the key is low
latency -- in other words, we don't really care about data throughput,
but rather getting the end-to-end TCP packet transfer time down.

I know there's quite a few networking folks and kernel hackers on this
list, so I thought I'd see if anyone was interested (or knows someone
who might be interested) in doing a few hours of consultancy work to
give us some pointers on this. I'm a competent programmer, but
kernel-level network programming is not my area of expertise.

I'm happy to receive some pointers via this list -- and others might
benefit from that too -- but I'm also keen on some dedicated
consultancy hours if anyone's interested.

Thanks,
Ben.
