From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix soft lockup with multi-interrupt TSECs
Date: Mon, 12 Jan 2009 21:57:47 -0800 (PST)
Message-ID: <20090112.215747.18333160.davem@davemloft.net>
References: <20090112183835.GA25390@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, afleming@freescale.com,
	dai.haruki@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42938
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755218AbZAMF5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 00:57:47 -0500
In-Reply-To: <20090112183835.GA25390@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Mon, 12 Jan 2009 21:38:35 +0300

> This patch fixes following bug:
> 
> BUG: soft lockup - CPU#0 stuck for 61s! [S03mountvirtfs-:922]
 ...
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks Anton.
