From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/6] netdev: bfin_mac: handler RX
	status errors
Date: Thu, 21 Jan 2010 04:31:17 -0500
Message-ID: <8bd0f97a1001210131w74d53c82h3f548e645bb14be7@mail.gmail.com>
References: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
	<20100121.011445.26519711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, pmeerw@pmeerw.net,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:65185 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab0AUJbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 04:31:37 -0500
Received: by gxk9 with SMTP id 9so7053625gxk.8
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2010 01:31:37 -0800 (PST)
In-Reply-To: <20100121.011445.26519711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2010 at 04:14, David Miller wrote:
> This patch set doesn't apply cleanly to net-next-2.6, please
> respin.

i thought you said you merged the patch i sent out earlier ?
bfin_mac: use the newer CLKBUFOE bit name via asm/dpmc.h
-mike
