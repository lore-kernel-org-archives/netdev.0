From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/6] phylib: cleanups
Date: Sat, 04 Jan 2014 04:28:02 +0300
Message-ID: <52C763A2.10901@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:41420 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754392AbaADA17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:27:59 -0500
Received: by mail-la0-f44.google.com with SMTP id e16so615246lan.31
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 16:27:58 -0800 (PST)
In-Reply-To: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2014 04:13 AM, Sergei Shtylyov wrote:

>     This patchset mainly cleans up the phylib's coding style but then also
> removes some historically unused stuff.

    Sclerosis strikes again: forgot to mention that the patches are against 
'net-next.git' repo.

> [1/6] phy: coding style fixes
> [2/6] mdio_bus: coding style fixes
> [3/6] phy: kill useless local variables
> [4/6] phy: kill excess code
> [5/6] phylib: remove unused adjust_state callback
> [6/6] phylib: make phy_scan_fixups() static

WBR, Sergei
