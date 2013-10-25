From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ax88179_178a: Remove AX_MEDIUM_ALWAYS_ONE bit in
 AX_MEDIUM_STATUS_MODE register to avoid TX throttling
Date: Fri, 25 Oct 2013 19:27:34 -0400 (EDT)
Message-ID: <20131025.192734.1224686649926183282.davem@davemloft.net>
References: <1382597905-2393-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, allan@asix.com.tw, louis@asix.com.tw
To: freddy@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382597905-2393-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: freddy@asix.com.tw
Date: Thu, 24 Oct 2013 14:58:25 +0800

> From: Freddy Xin <freddy@asix.com.tw>
> 
> Remove AX_MEDIUM_ALWAYS_ONE in AX_MEDIUM_STATUS_MODE register.
> Setting this bit may cause TX throttling in Half-Duplex mode.
> 
> Signed-off-by: Freddy Xin <freddy@asix.com.tw>

Applied.
