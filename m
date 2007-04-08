From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: mm snapshot broken-out-2007-04-07-03-27.tar.gz uploaded
Date: Sun, 8 Apr 2007 15:26:31 +0200
Message-ID: <6bffcb0e0704080626nfb89c3cif9fd572a4ac58a30@mail.gmail.com>
References: <200704071029.l37ATdKR032505@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: "Thomas Gleixner" <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:1391 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbXDHN0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2007 09:26:31 -0400
Received: by py-out-1112.google.com with SMTP id a29so816917pyi
        for <netdev@vger.kernel.org>; Sun, 08 Apr 2007 06:26:31 -0700 (PDT)
In-Reply-To: <200704071029.l37ATdKR032505@shell0.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/04/07, akpm@linux-foundation.org <akpm@linux-foundation.org> wrote:
> The mm snapshot broken-out-2007-04-07-03-27.tar.gz has been uploaded to
>
>    ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/mm/broken-out-2007-04-07-03-27.tar.gz
>

Thomas,

I get a lot of "NOHZ: local_softirq_pending 0a" messages, when I run
netperf2 test.

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/broken-out-2007-04-07-03-27/mm-config
http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/broken-out-2007-04-07-03-27/mm-dmesg2

Regards,
Michal

-- 
Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)
