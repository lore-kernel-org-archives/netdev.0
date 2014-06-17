From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] isdn: hisax: Drop duplicate Kconfig entry
Date: Mon, 16 Jun 2014 21:31:55 -0700 (PDT)
Message-ID: <20140616.213155.1969199453902048889.davem@davemloft.net>
References: <1402906177.13305.1.camel@chaos.site>
	<1402906435.13305.6.camel@chaos.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de, sam@ravnborg.org
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbaFQEb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 00:31:56 -0400
In-Reply-To: <1402906435.13305.6.camel@chaos.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Mon, 16 Jun 2014 10:13:55 +0200

> There are 2 HISAX_AVM_A1_PCMCIA Kconfig entries. The kbuild system
> ignores the second one, and apparently nobody noticed the problem so
> far, so let's remove that second entry.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied.
