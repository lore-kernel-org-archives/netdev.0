From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [PATCH] ax88179_178a: Correct the RX error
 definition in RX header
Date: Tue, 22 Oct 2013 15:44:07 -0400 (EDT)
Message-ID: <20131022.154407.194174277374996701.davem@davemloft.net>
References: <1382427131-2429-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, allan@asix.com.tw, louis@asix.com.tw
To: freddy@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382427131-2429-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: freddy@asix.com.tw
Date: Tue, 22 Oct 2013 15:32:10 +0800

> From: Freddy Xin <freddy@asix.com.tw>
> 
> Correct the definition of AX_RXHDR_CRC_ERR and
> AX_RXHDR_DROP_ERR. They are BIT29 and BIT31 in pkt_hdr
> seperately.
> 
> Signed-off-by: Freddy Xin <freddy@asix.com.tw>

Applied.
