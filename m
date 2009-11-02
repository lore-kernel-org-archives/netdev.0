From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET:KS8695: add API for get rx interrupt bit
Date: Sun, 01 Nov 2009 23:55:36 -0800 (PST)
Message-ID: <20091101.235536.58269945.davem@davemloft.net>
References: <1256907911.2148.87.camel@myhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: figo1802@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40867
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754037AbZKBHzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 02:55:12 -0500
In-Reply-To: <1256907911.2148.87.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Figo.zhang" <figo1802@gmail.com>
Date: Fri, 30 Oct 2009 21:05:11 +0800

> 1. Add API Add k8695_get_rx_enable_bit() for get Rx interrupt 
> enable/status bit.
> 2. add some comment or document about some functions and variables.
> 3.  update driver version to "1.02"
> 4. add napi_enable() and napi_disable() in open/close file method.
> 
> Signed-off-by: Figo.zhang <figo1802@gmail.com>

Patch applied to net-next-2.6, thanks.
