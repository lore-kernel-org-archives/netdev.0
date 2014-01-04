From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/6] phy: kill excess code
Date: Sat, 04 Jan 2014 19:29:35 +0300
Message-ID: <52C836EF.1010705@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com> <201401040419.14818.sergei.shtylyov@cogentembedded.com> <20140104073639.GB4261@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:48906 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbaADP3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 10:29:33 -0500
Received: by mail-lb0-f180.google.com with SMTP id x18so8907101lbi.11
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 07:29:31 -0800 (PST)
In-Reply-To: <20140104073639.GB4261@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/04/2014 10:36 AM, Richard Cochran wrote:

>> Remove tens of lines of unnecessary code:

>> - kill empty lines between a function call and its result check;

> ...

>> - kill excess empty lines.

> Blank lines are not LOC. They can improve legibility.

    Both kinds of empty lines are consistently avoided by all other code I had 
to read. They don't really improve anything.

> Thanks,
> Richard

WBR, Sergei
