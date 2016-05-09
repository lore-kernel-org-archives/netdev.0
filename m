From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Documentation/networking: more accurate LCO
 explanation
Date: Sun, 08 May 2016 23:55:36 -0400 (EDT)
Message-ID: <20160508.235536.432320048530190707.davem@davemloft.net>
References: <1462555663-10216-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	ecree@solarflare.com
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbcEIDzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:55:39 -0400
In-Reply-To: <1462555663-10216-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Fri,  6 May 2016 20:27:43 +0300

> In few places the term "ones-complement sum" was used but the actual
> meaning is "the complement of the ones-complement sum".
> 
> Also, avoid enclosing long statements with underscore, to ease
> readability.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Acked-by: Edward Cree <ecree@solarflare.com>

Applied.
