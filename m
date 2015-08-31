From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] ip-tunnel: Use API to access tunnel metadata
 options.
Date: Mon, 31 Aug 2015 11:05:03 +0200
Message-ID: <20150831090503.GB12707@pox.localdomain>
References: <1440983378-2107-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33237 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbHaJFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 05:05:06 -0400
Received: by wicpl12 with SMTP id pl12so26025509wic.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 02:05:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440983378-2107-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/15 at 06:09pm, Pravin B Shelar wrote:
> Currently tun-info options pointer is used in few cases to
> pass options around. But tunnel options can be accessed using
> ip_tunnel_info_opts() API without using the pointer. Following
> patch removes the redundant pointer and consistently make use
> of API.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Nice!

Acked-by: Thomas Graf <tgraf@suug.ch>
