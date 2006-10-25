From: "Richard Bollinger" <rabollinger@gmail.com>
Subject: Re: tg3 driver fails with on-board BCM95789 NICS (GigaByte GA-7VCSV)
Date: Wed, 25 Oct 2006 09:36:15 -0400
Message-ID: <7744a2840610250636i1db14db9kd4975a610f60e10e@mail.gmail.com>
References: <7744a2840610241432i42364aaap672f8eb5bf25c066@mail.gmail.com>
	 <1551EAE59135BE47B544934E30FC4FC093FC6D@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <20061024.213350.74746920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:62485 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030247AbWJYNgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 09:36:17 -0400
Received: by ug-out-1314.google.com with SMTP id 32so91831ugm
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 06:36:16 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061024.213350.74746920.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/06, David Miller <davem@davemloft.net> wrote:
> It's an interrupt routing problem for sure, Adrian Bunk
> posted a potential fix to this poster an hour or so
> ago.

I'm running with arch=i386 and the only related postings I see are for
x86_64 :-(.
