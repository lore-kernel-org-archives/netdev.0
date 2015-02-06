From: Thomas Graf <tgraf@suug.ch>
Subject: Re: panic on boot with latest net-next
Date: Fri, 6 Feb 2015 22:10:28 +0000
Message-ID: <20150206221028.GA13706@casper.infradead.org>
References: <54D52BD6.2080109@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36375 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbBFWKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 17:10:32 -0500
Content-Disposition: inline
In-Reply-To: <54D52BD6.2080109@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/15 at 03:02pm, Josh Hunt wrote:
> I'm hitting the following crash on boot with the latest net-next
> (2ca292d968ef20cb04f31192d1f626bd8d782960):

Thanks for the report.

This should be fixed by the patches posted in the thread:
[PATCH 0/6 v2 net-next] rhashtable fixes
