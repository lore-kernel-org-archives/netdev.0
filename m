From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] usbnet: ax88179_178a: add .reset_resume
 hook
Date: Fri, 28 Jun 2013 21:40:36 -0700 (PDT)
Message-ID: <20130628.214036.771763171931363297.davem@davemloft.net>
References: <1372324603-4556-1-git-send-email-dchang@suse.com>
	<1372324603-4556-2-git-send-email-dchang@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jlee@suse.com
To: dchang@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372324603-4556-2-git-send-email-dchang@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Chang <dchang@suse.com>
Date: Thu, 27 Jun 2013 17:16:43 +0800

> I tested with the AX88179 usb dongle, if without .reset_resume hook,
> after S3/S4 resume you have to enable network interface or reload the
> dirver module manually otherwise the network interface can not work.
> 
> Signed-off-by: David Chang <dchang@suse.com>

Applied.
