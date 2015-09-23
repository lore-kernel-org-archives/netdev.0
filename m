From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ch9200: Convert to use module_usb_driver
Date: Tue, 22 Sep 2015 17:35:13 -0700 (PDT)
Message-ID: <20150922.173513.2086247227134441147.davem@davemloft.net>
References: <1442906989-10664-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjg59@srcf.ucam.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759812AbbIWAfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 20:35:14 -0400
In-Reply-To: <1442906989-10664-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 22 Sep 2015 09:29:49 +0200

> Converts the ch9200 driver to use the module_usb_driver() macro which
> makes the code smaller and a bit simpler.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
