From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] phy: kill excess code
Date: Sat, 4 Jan 2014 16:42:29 +0100
Message-ID: <20140104154229.GE4925@netboy>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
 <201401040419.14818.sergei.shtylyov@cogentembedded.com>
 <20140104073639.GB4261@netboy>
 <52C836EF.1010705@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:54080 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbaADPmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 10:42:40 -0500
Received: by mail-ea0-f175.google.com with SMTP id z10so7124262ead.20
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 07:42:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52C836EF.1010705@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 04, 2014 at 07:29:35PM +0300, Sergei Shtylyov wrote:
> 
>    Both kinds of empty lines are consistently avoided by all other
> code I had to read. They don't really improve anything.

But both your subject line and body talk about lines of code. Just
removing blank lines is not the same as removing "excess code."

Thanks,
Richard
