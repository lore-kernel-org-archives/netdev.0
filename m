From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neterion: s2io: Use module_pci_driver
Date: Thu, 09 Jul 2015 00:19:24 -0700 (PDT)
Message-ID: <20150709.001924.1336350289907335948.davem@davemloft.net>
References: <20150709045539.GA7052@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbbGIHTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 03:19:25 -0400
In-Reply-To: <20150709045539.GA7052@vaishali-Ideapad-Z570>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Thu, 9 Jul 2015 10:25:39 +0530

> Use module_pci_driver for drivers whose init and exit functions
> only register and unregister, respectively.
> 
> A simplified version of the Coccinelle semantic patch that performs
> this transformation is as follows:
 ...
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied, thanks.
