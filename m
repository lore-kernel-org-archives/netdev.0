From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [iproute2] lib utils: fix family during af_bit_len calculation
Date: Tue, 24 Mar 2015 08:35:04 +0300
Message-ID: <20150324053502.GA10432@paralelels.com>
Reply-To: <1426645109-3411-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Stephen Hemminger <shemminger@osdl.org>, <netdev@vger.kernel.org>
To: <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:43430 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbbCXFf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 01:35:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> commit f3a2ddc124e0 ("lib utils: Use helpers to get AF bit/byte len")
> used a wrong family or family of zero in the default case
> during af_bit_len calculation causing ip route commands to
> fail with below error
> 
> Error: an inet prefix is expected rather than "10.0.2.14/24".
>
> Reported-by: Sven-Haegar Koch <haegar@sdinet.de>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Andrew Vagin <avagin@parallels.com>
