From: Tina Ruchandani <ruchandani.tina@gmail.com>
Subject: Re: [PATCH v3] isdn: Use ktime_t instead of 'struct timeval'
Date: Sat, 30 May 2015 23:27:13 -0700
Message-ID: <CAB__kknpAuLRxO9XhoVSwxZqryUk3ACBqJTHTaWhc_XqxZQ-KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arnd Bergmann <arnd@arndb.de>, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org, y2038@lists.linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34449 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861AbbEaG1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 02:27:13 -0400
Received: by pdbki1 with SMTP id ki1so84309167pdb.1
        for <netdev@vger.kernel.org>; Sat, 30 May 2015 23:27:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> This doesn't compile:
>

Oops, I sent an older version of the patch with a typo. I've correct
this in a v4. (NS_PER_SEC -> NSEC_PER_SEC). Thanks for taking a look
at this.

Tina
