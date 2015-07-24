From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] lwtunnel: change prototype of
 lwtunnel_state_get()
Date: Fri, 24 Jul 2015 12:41:50 +0200
Message-ID: <20150724104150.GB15706@pox.localdomain>
References: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
 <1437733716-4494-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37306 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbbGXKlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 06:41:53 -0400
Received: by wibud3 with SMTP id ud3so22098585wib.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 03:41:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437733716-4494-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/15 at 12:28pm, Nicolas Dichtel wrote:
> It saves some lines and simplify a bit the code when the state is returning
> by this function. It's also useful to handle a NULL entry.
> 
> To avoid too long lines, I've also renamed lwtunnel_state_get() and
> lwtunnel_state_put() to lwtstate_get() and lwtstate_put().
> 
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
