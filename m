From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] phy: kill excess code
Date: Sat, 4 Jan 2014 08:36:40 +0100
Message-ID: <20140104073639.GB4261@netboy>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
 <201401040419.14818.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:48799 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbaADHgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 02:36:52 -0500
Received: by mail-ea0-f181.google.com with SMTP id m10so6975172eaj.26
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 23:36:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <201401040419.14818.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 04, 2014 at 04:19:14AM +0300, Sergei Shtylyov wrote:
> Remove tens of lines of unnecessary code:
> 
> - kill empty lines between a function call and its result check;

...

> - kill excess empty lines.

Blank lines are not LOC. They can improve legibility.

Thanks,
Richard
