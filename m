From: Ben Hoyt <benhoyt@gmail.com>
Subject: Re: Minimizing TCP latency
Date: Tue, 30 Mar 2010 15:36:46 +1300
Message-ID: <7c93bf1e1003291936v4b0f610eiae07c236dfc72047@mail.gmail.com>
References: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>
	 <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>
	 <1269876229.2092.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:47426 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788Ab0C3Cgq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 22:36:46 -0400
Received: by pwi5 with SMTP id 5so7374975pwi.19
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 19:36:46 -0700 (PDT)
In-Reply-To: <1269876229.2092.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Choose low-latency NICs. =A0Read the tuning guide, but run your own
> benchmarks.

Is this the tuning guide you're referring to?
http://fasterdata.es.net/TCP-tuning/linux.html

>> FYI, we're using RHE release 4 and kernel version 2.6.9 on x86_64 ma=
chines.
> You're not going to get much help here in working on that kernel.

Thanks for that. I didn't realise 2.6.9 was so old -- I'll upgrade.

-Ben
