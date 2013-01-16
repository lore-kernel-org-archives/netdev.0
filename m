From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: dm9601: Fix incorrect command
Date: Wed, 16 Jan 2013 15:55:27 -0500 (EST)
Message-ID: <20130116.155527.1163555891632434773.davem@davemloft.net>
References: <1358228341-2104-1-git-send-email-tushar.behera@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	jacmet@sunsite.dk, patches@linaro.org, ming.lei@canonical.com
To: tushar.behera@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358228341-2104-1-git-send-email-tushar.behera@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tushar Behera <tushar.behera@linaro.org>
Date: Tue, 15 Jan 2013 11:09:01 +0530

> commit 24b1042c4eb2 ("usbnet: dm9601: apply introduced usb command
> APIs") removes the distiction between DM_WRITE_REG and DM_WRITE_REGS
> command. The distiction is reintroduced to the driver so that the
> functionality of the driver remains same.
> 
> CC: Ming Lei <ming.lei@canonical.com>
> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>

Applied, thanks.
