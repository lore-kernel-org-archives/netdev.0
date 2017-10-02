From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4] r8152: add Linksys USB3GIGV1 id
Date: Sun, 01 Oct 2017 22:39:54 -0700 (PDT)
Message-ID: <20171001.223954.160035131695050852.davem@davemloft.net>
References: <20170928183500.61199-1-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, oneukum@suse.com, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: grundler@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928183500.61199-1-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@chromium.org>
Date: Thu, 28 Sep 2017 11:35:00 -0700

> This linksys dongle by default comes up in cdc_ether mode.
> This patch allows r8152 to claim the device:
>    Bus 002 Device 002: ID 13b1:0041 Linksys
> 
> Signed-off-by: Grant Grundler <grundler@chromium.org>

Applied, thanks.
