From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/6] phylib: cleanups
Date: Sat, 04 Jan 2014 19:41:09 +0300
Message-ID: <52C839A5.2070807@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:42108 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbaADPlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 10:41:07 -0500
Received: by mail-la0-f53.google.com with SMTP id mc6so8688055lab.26
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 07:41:06 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-87-5.pppoe.mtu-net.ru. [91.76.87.5])
        by mx.google.com with ESMTPSA id ld10sm49947039lab.8.2014.01.04.07.41.04
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 07:41:05 -0800 (PST)
In-Reply-To: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/04/2014 04:13 AM, Sergei Shtylyov wrote:

>     This patchset mainly cleans up the phylib's coding style but then also
> removes some historically unused stuff.

> [1/6] phy: coding style fixes
> [2/6] mdio_bus: coding style fixes

    <linux/phy.h> also causes checkpatch.pl errors/warnings/checks but I just 
forgot about it. I feel the series should be extended now...

> [3/6] phy: kill useless local variables
> [4/6] phy: kill excess code
> [5/6] phylib: remove unused adjust_state callback
> [6/6] phylib: make phy_scan_fixups() static

WBR, Sergei
