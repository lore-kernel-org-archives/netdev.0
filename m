From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: [PATCH iproute2] fix ip -force -batch to continue on errors
Date: Thu, 19 Mar 2015 18:58:41 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1503191857360.13144@aurora64.sdinet.de>
References: <1426645592-4002-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from blackhole.sdinet.de ([176.9.52.58]:54907 "EHLO mail.sdinet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752931AbbCSR6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 13:58:49 -0400
In-Reply-To: <1426645592-4002-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2015, roopa@cumulusnetworks.com wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch replaces exits with returns in several
> iproute2 commands. This fixes `ip -batch -force`
> to not exit but continue on errors.

Thanks a lot!
Slight rejects adding it to Debian's iproute2 3.16.0-2, but after 
fixing them up works great!

c'ya
sven-haegar

-- 
Three may keep a secret, if two of them are dead.
- Ben F.
