From: Xue Ying <ying.xue0@gmail.com>
Subject: Re: [BUG]  TIPC handling of -ERESTARTSYS in connect()
Date: Thu, 01 Nov 2012 14:35:29 +0800
Message-ID: <50921831.3020505@gmail.com>
References: <503F84CF.208@genband.com> <504085D9.3010907@windriver.com> <5040D3C4.2010308@genband.com> <5040D5D9.4040802@genband.com> <504420FD.4030908@windriver.com> <5046161F.8070703@genband.com> <5091ADC6.4000307@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ying Xue <ying.xue@windriver.com>, netdev <netdev@vger.kernel.org>,
	Allan Stephens <allan.stephens@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33420 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749Ab2KAGfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 02:35:39 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so945854bkc.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 23:35:38 -0700 (PDT)
In-Reply-To: <5091ADC6.4000307@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
> I finally got a chance to test this out, and it does indeed fix the 
> problem.  Please push it upstream.
>
> Tested-by: Chris Friesen <chris.friesen@genband.com>
>

Thanks for your hard working, I will submit it again.

Regards,
Ying

> Chris
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
