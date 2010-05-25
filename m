From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] be2net: Bug fix in init code in probe
Date: Mon, 24 May 2010 18:39:21 -0700 (PDT)
Message-ID: <20100524.183921.174070288.davem@davemloft.net>
References: <20100524112033.GA3666@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52212
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758038Ab0EYBjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 21:39:11 -0400
In-Reply-To: <20100524112033.GA3666@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Mon, 24 May 2010 16:50:47 +0530

> PCI function reset needs to invoked after fw init ioctl is issued.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>

Applied, thanks.
