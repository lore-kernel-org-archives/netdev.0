From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] irda: add missing BKL in irnet_ppp ioctl
Date: Wed, 03 Feb 2010 20:15:04 -0800 (PST)
Message-ID: <20100203.201504.239397745.davem@davemloft.net>
References: <1265048496-8149-1-git-send-email-cascardo@holoscopio.com>
	<1265048496-8149-2-git-send-email-cascardo@holoscopio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@redhat.com, samuel@sortiz.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: cascardo@holoscopio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53035
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756494Ab0BDEOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:14:50 -0500
In-Reply-To: <1265048496-8149-2-git-send-email-cascardo@holoscopio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Date: Mon,  1 Feb 2010 16:21:35 -0200

> One ioctl has been forgotten when the BKL was push down into irnet_ppp
> ioctl function.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>

Applied.
