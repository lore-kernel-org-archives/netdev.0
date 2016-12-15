From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH] net: sfc: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 15 Dec 2016 08:57:04 +0000
Message-ID: <a97fd284-97ed-b11f-0fae-6d02f09d48b2@solarflare.com>
References: <1481757173-16000-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        <linux-net-drivers@solarflare.com>, <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:24606 "EHLO
        nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757727AbcLOI5P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 03:57:15 -0500
In-Reply-To: <1481757173-16000-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

n 14/12/16 23:12, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Thanks Philippe. We'll get some testing done on this.

Bert.
