From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/6] phy: kill useless local variables
Date: Sat, 4 Jan 2014 08:34:05 +0100
Message-ID: <20140104073403.GA4261@netboy>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
 <201401040417.39742.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:37734 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150AbaADHeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 02:34:17 -0500
Received: by mail-ea0-f180.google.com with SMTP id f15so6952098eak.25
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 23:34:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <201401040417.39742.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 04, 2014 at 04:17:39AM +0300, Sergei Shtylyov wrote:
> A number of functions (especially in phy.c) has local variables that were hardly
> needed in the first place -- remove them.

I scanned over this patch, and the 'improvement' is marginal if at
all, IMHO. The code was fine how it was.

Thanks,
Richard
