From: david@lang.hm
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sun, 6 Jul 2008 13:52:01 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0807061351040.11010@asgard.lang.hm>
References: <1215178035.10393.763.camel@pmac.infradead.org>  <486E2818.1060003@garzik.org> <20080704142753.27848ff8@lxorguk.ukuu.org.uk>  <20080704.134329.209642254.davem@davemloft.net>  <20080704220444.011e7e61@lxorguk.ukuu.org.uk>
 <alpine.DEB.1.10.0807061311030.11010@asgard.lang.hm> <1215376034.3189.127.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	andi@firstfloor.org, tytso@mit.edu, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lang.hm ([64.81.33.126]:40382 "EHLO bifrost.lang.hm"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757451AbYGFUwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 16:52:00 -0400
In-Reply-To: <1215376034.3189.127.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 6 Jul 2008, David Woodhouse wrote:

> On Sun, 2008-07-06 at 13:17 -0700, david@lang.hm wrote:
>> if David W were to make it possible to not use the load_firmware() call to
>> userspace and build the firmware into the driver (be it in a monolithic
>> kernel or the module that contains the driver)
>
> You _can_ build the firmware into the kernel.

right, but not into a module. you have half of the answer in place, but 
not all of it.

David Lang
