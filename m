From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/6] phy: kill excess code
Date: Sun, 05 Jan 2014 03:50:30 +0300
Message-ID: <52C8AC56.7030804@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com> <201401040419.14818.sergei.shtylyov@cogentembedded.com> <20140104073639.GB4261@netboy> <52C836EF.1010705@cogentembedded.com> <20140104154229.GE4925@netboy> <52C83B25.7030505@cogentembedded.com> <20140104155114.GF4925@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:48457 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579AbaADXuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:50:32 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so9116490lab.29
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:50:30 -0800 (PST)
In-Reply-To: <20140104155114.GF4925@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/04/2014 06:51 PM, Richard Cochran wrote:

>>>>     Both kinds of empty lines are consistently avoided by all other
>>>> code I had to read. They don't really improve anything.

>>> But both your subject line and body talk about lines of code. Just
>>> removing blank lines is not the same as removing "excess code."

>>     To me, all source file lines are code. So what you are
>> suggesting, splitting the patch?

> Yes, exactly that.

    OK, done.

> If the title reads, "fix whitespace errors" or "remove blank lines",
> then I don't need to waste my time looking at it.

    Maybe I'd go too far and remove too much? :-)

> But if it reads, "remove excess code", then I want to make sure that
> you don't go and delete something important.

    I don't delete the meaningful code at all, just kind of compact it. Maybe 
I should have renamed that patch...

> Thanks,
> Richard

WBR, Sergei
