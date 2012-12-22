From: Zhiyun Qian <zhiyunq@umich.edu>
Subject: Re: TCP sequence number inference attack on Linux
Date: Fri, 21 Dec 2012 19:08:31 -0500
Message-ID: <CALvgte-ai25chfrDUgz1T+q93pBK_2fLmrODa5Dz9qi5E0m0mw@mail.gmail.com>
References: <CALvgte86miv450KnOcFRR-oEm_f=qRXarDfQkyU7T3OLqq816A@mail.gmail.com>
	<1356114663.21834.7697.camel@edumazet-glaptop>
	<CALvgte9x4LWV8rsquKzNoVcXM14xZjvyuTgpHr-ynZXfGtzzpw@mail.gmail.com>
	<1356118052.21834.7793.camel@edumazet-glaptop>
	<CALvgte9WJRR95B5WCTavF0w3Kvf+MksZtyY4OQ=ioAe71BasCw@mail.gmail.com>
	<1356129948.21834.8002.camel@edumazet-glaptop>
	<CALvgte-tpvyBF608MahqLc_JFZNzg2q1FpsUY72fDDicbdsBWA@mail.gmail.com>
	<1356134481.21834.8090.camel@edumazet-glaptop>
	<1356134676.21834.8096.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45302 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766Ab2LVAId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 19:08:33 -0500
Received: by mail-we0-f174.google.com with SMTP id x10so2424632wey.33
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 16:08:31 -0800 (PST)
In-Reply-To: <1356134676.21834.8096.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see. If you need any help, just let me know! E.g., I can definitely
help review the patches.

-Zhiyun

On Fri, Dec 21, 2012 at 7:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-12-21 at 16:01 -0800, Eric Dumazet wrote:
>
>> I began coding a serie of patches.
>
> My goal is to make very small patches, to ease code review, and
> eventually come to a state where we have more factorized code.
>
>
>
