From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] Remove /proc/net/ip_vs_lblcr
Date: Tue, 30 Oct 2007 15:40:57 -0700 (PDT)
Message-ID: <20071030.154057.183093042.davem@davemloft.net>
References: <20071030131257.GB6210@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbXJ3WlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 18:41:13 -0400
In-Reply-To: <20071030131257.GB6210@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Tue, 30 Oct 2007 16:12:57 +0300

> It's under CONFIG_IP_VS_LBLCR_DEBUG option which never existed.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied, thanks.
