From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri_sbus: use request_firmware
Date: Sat, 04 Apr 2009 16:38:57 -0700 (PDT)
Message-ID: <20090404.163857.103749063.davem@davemloft.net>
References: <1238701097.3099.82.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dwmw2@infradead.org
To: jaswinder@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754576AbZDDXjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 19:39:08 -0400
In-Reply-To: <1238701097.3099.82.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Fri, 03 Apr 2009 01:08:17 +0530

> Firmware blob looks like this...
> 
>         __be16 lanai4_data_size
>         unsigned char lanai4_code[]
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

Applied, thanks.
