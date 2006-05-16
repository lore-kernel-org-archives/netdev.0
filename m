From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipx: correct return type of ipx_map_frame_type
Date: Tue, 16 May 2006 15:18:09 -0700 (PDT)
Message-ID: <20060516.151809.76222193.davem@davemloft.net>
References: <20060516184940.GL10143@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, acme@conectiva.com.br, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56480
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932210AbWEPWTD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 18:19:03 -0400
To: adobriyan@gmail.com
In-Reply-To: <20060516184940.GL10143@mipter.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 16 May 2006 22:49:40 +0400

> Casting BE16 to int and back may or may not work. Correct, to be sure.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks.
