From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 1/2] linux-firmware: bnx2: Update firmware to 6.0.x.
Date: Sun, 23 Jan 2011 03:40:35 +1000
Message-ID: <1295718036.2980.1.camel@macbook.infradead.org>
References: <1295473811-17443-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:37943 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482Ab1AVRkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 12:40:41 -0500
In-Reply-To: <1295473811-17443-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 13:50 -0800, Michael Chan wrote:
> upstream kernel commit 22fa159d37efbfe781bbb99279efe83f58b87d29
> 
> - Improved flow control and simplified interface
> - Use hardware RSS indirection table instead of the slower firmware-
>   based table
> - Lower latency interrupt on 5709
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  bnx2/bnx2-mips-06-6.0.15.fw   |  Bin 0 -> 92780 bytes
>  bnx2/bnx2-mips-09-6.0.17.fw   |  Bin 0 -> 103488 bytes
>  bnx2/bnx2-rv2p-06-6.0.15.fw   |  Bin 0 -> 5696 bytes
>  bnx2/bnx2-rv2p-09-6.0.17.fw   |  Bin 0 -> 6104 bytes
>  bnx2/bnx2-rv2p-09ax-6.0.17.fw |  Bin 0 -> 6616 bytes
>  5 files changed, 0 insertions(+), 0 deletions(-)
>  create mode 100644 bnx2/bnx2-mips-06-6.0.15.fw
>  create mode 100644 bnx2/bnx2-mips-09-6.0.17.fw
>  create mode 100644 bnx2/bnx2-rv2p-06-6.0.15.fw
>  create mode 100644 bnx2/bnx2-rv2p-09-6.0.17.fw
>  create mode 100644 bnx2/bnx2-rv2p-09ax-6.0.17.fw

Please could you update the WHENCE file accordingly? 

-- 
dwmw2

