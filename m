From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_net: runtime pm wrap mdio read and write
Date: Wed, 26 Feb 2014 22:23:42 +0300
Message-ID: <530E3F3E.2080405@cogentembedded.com>
References: <1393433319-22685-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	magnus.damn@opensource.se, horms@verge.net.au
To: Ben Dooks <ben.dooks@codethink.co.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:47547 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753072AbaBZSXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 13:23:49 -0500
Received: by mail-lb0-f170.google.com with SMTP id s7so914674lbd.15
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 10:23:48 -0800 (PST)
In-Reply-To: <1393433319-22685-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, forgot to say, please fix the subject: s/sh_net/sh_eth/...
