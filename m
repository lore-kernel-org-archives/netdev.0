From: jamal <hadi@cyberus.ca>
Subject: Re: [NET_SCHED 00/09]: sch_ingress cleanups
Date: Sun, 20 Jan 2008 10:31:36 -0500
Message-ID: <1200843096.4433.145.camel@localhost>
References: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:55711 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbYATPbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 10:31:43 -0500
Received: by py-out-1112.google.com with SMTP id u52so2387783pyb.10
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 07:31:40 -0800 (PST)
In-Reply-To: <20080120143130.27801.94188.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-20-01 at 15:32 +0100, Patrick McHardy wrote:
> These patches clean up sch_ingress by reformatting the code to match the
> usual kernel style, removing lots of debugging statements that seem
> unnecessary after years of stable operation, removing some "future use"
> stuff that doesn't seem likely to ever get used and some minor additional
> cleanups.
> 

Patrick - if you are in mopping-mode then you will find some of the same
things in dsmark (LinuxWay(tm)).

For all patches:
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

