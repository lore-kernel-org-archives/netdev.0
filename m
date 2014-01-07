From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: correct some messages
Date: Tue, 07 Jan 2014 00:45:50 -0500 (EST)
Message-ID: <20140107.004550.1024697128774275576.davem@davemloft.net>
References: <1388999999-9218-1-git-send-email-hayeswang@realtek.com>
	<1389064702-1173-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389064702-1173-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 7 Jan 2014 11:18:22 +0800

>  - Replace pr_warn_ratelimited() with net_ratelimit() and netdev_warn().
>  - Adjust the algnment of some messages.
>  - Remove the peroid.
>  - Fix some messages don't have terminating newline.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

I only want major bug fixes in 'net' at this time so I've applied
this to 'net-next'.

Thanks.
