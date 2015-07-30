From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwtunnel: Make lwtun_encaps[] static
Date: Wed, 29 Jul 2015 22:59:54 -0700 (PDT)
Message-ID: <20150729.225954.1199356192498170951.davem@davemloft.net>
References: <66e6473d98879c465cf4965d44230374c716ed25.1438155918.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbG3F7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 01:59:55 -0400
In-Reply-To: <66e6473d98879c465cf4965d44230374c716ed25.1438155918.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 29 Jul 2015 09:45:40 +0200

> Any external user should use the registration API instead of
> accessing this directly.
> 
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
