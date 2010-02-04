From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] irda: unbalanced lock_kernel in irnet_ppp
Date: Wed, 03 Feb 2010 20:14:58 -0800 (PST)
Message-ID: <20100203.201458.27746666.davem@davemloft.net>
References: <1265048496-8149-1-git-send-email-cascardo@holoscopio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@redhat.com, samuel@sortiz.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: cascardo@holoscopio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53030
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756407Ab0BDEOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:14:47 -0500
In-Reply-To: <1265048496-8149-1-git-send-email-cascardo@holoscopio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Date: Mon,  1 Feb 2010 16:21:34 -0200

> Add the missing unlock_kernel in one ioctl operation.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>

Applied.
