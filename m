From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] ss: Show inet and unix sockets' shutdown state
Date: Thu, 25 Oct 2012 20:00:54 +0200
Message-ID: <1351188054.6537.196.camel@edumazet-glaptop>
References: <50893BAF.7030500@parallels.com> <50893E14.60001@parallels.com>
	 <20121025085229.3aa43b68@nehalam.linuxnetplumber.net>
	 <1351184010.6537.158.camel@edumazet-glaptop>
	 <20121025100922.12ed2061@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53979 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759716Ab2JYSA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 14:00:57 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so950501bkc.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 11:00:56 -0700 (PDT)
In-Reply-To: <20121025100922.12ed2061@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-25 at 10:09 -0700, Stephen Hemminger wrote:

> I don't want the stashed kernel headers to get out of date with kernel exported ones.
> 
> People who want to test early features are free to build their own pre-release versions.
> --

Have you considered an iproute2-next tree, it would really help us a
lot.

Just to be clear, were the patches 1-4 accepted ?

(UDP diag was added kernel in December 2011)

Thanks
