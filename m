From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ISDN, hfcsusb: Don't leak in hfcsusb_ph_info()
Date: Sat, 11 Jun 2011 18:59:20 -0700 (PDT)
Message-ID: <20110611.185920.1234962334048234649.davem@davemloft.net>
References: <alpine.LNX.2.00.1106111832270.23835@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sprenger@moving-bytes.de,
	info@bachem-it.com
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1106111832270.23835@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sat, 11 Jun 2011 18:36:42 +0200 (CEST)

> We leak the memory allocated to 'phi' when the variable goes out of scope 
> in hfcsusb_ph_info().
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied, thanks Jesper.
