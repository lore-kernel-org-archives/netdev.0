From: Ben Hoyt <benhoyt@gmail.com>
Subject: Minimizing TCP latency
Date: Mon, 29 Mar 2010 14:29:33 +1300
Message-ID: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:54985 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460Ab0C2B3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 21:29:33 -0400
Received: by pwi5 with SMTP id 5so6225936pwi.19
        for <netdev@vger.kernel.org>; Sun, 28 Mar 2010 18:29:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oops, very sorry, I replied to an existing message but forgot to edit
the subject line to start a new thread. Try again:

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
