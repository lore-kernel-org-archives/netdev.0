From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] phy: kill excess code
Date: Sat, 4 Jan 2014 16:51:14 +0100
Message-ID: <20140104155114.GF4925@netboy>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
 <201401040419.14818.sergei.shtylyov@cogentembedded.com>
 <20140104073639.GB4261@netboy>
 <52C836EF.1010705@cogentembedded.com>
 <20140104154229.GE4925@netboy>
 <52C83B25.7030505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:41968 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbaADPv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 10:51:26 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so6138366eek.13
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 07:51:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52C83B25.7030505@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 04, 2014 at 07:47:33PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/04/2014 06:42 PM, Richard Cochran wrote:
> 
> >>    Both kinds of empty lines are consistently avoided by all other
> >>code I had to read. They don't really improve anything.
> 
> >But both your subject line and body talk about lines of code. Just
> >removing blank lines is not the same as removing "excess code."
> 
>    To me, all source file lines are code. So what you are
> suggesting, splitting the patch?

Yes, exactly that.

If the title reads, "fix whitespace errors" or "remove blank lines",
then I don't need to waste my time looking at it.

But if it reads, "remove excess code", then I want to make sure that
you don't go and delete something important.

Thanks,
Richard
