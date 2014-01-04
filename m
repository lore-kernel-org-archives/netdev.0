From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/6] phy: kill excess code
Date: Sat, 04 Jan 2014 19:47:33 +0300
Message-ID: <52C83B25.7030505@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com> <201401040419.14818.sergei.shtylyov@cogentembedded.com> <20140104073639.GB4261@netboy> <52C836EF.1010705@cogentembedded.com> <20140104154229.GE4925@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:39129 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408AbaADPrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 10:47:31 -0500
Received: by mail-la0-f54.google.com with SMTP id b8so8673023lan.41
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 07:47:29 -0800 (PST)
In-Reply-To: <20140104154229.GE4925@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/04/2014 06:42 PM, Richard Cochran wrote:

>>     Both kinds of empty lines are consistently avoided by all other
>> code I had to read. They don't really improve anything.

> But both your subject line and body talk about lines of code. Just
> removing blank lines is not the same as removing "excess code."

    To me, all source file lines are code. So what you are suggesting, 
splitting the patch?

> Thanks,
> Richard

WBR, Sergei
