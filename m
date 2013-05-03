From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 net-next] net/usb: new driver for RTL8152
Date: Thu, 2 May 2013 19:33:28 -0700
Message-ID: <20130503023328.GB26712@kroah.com>
References: <1366965948-1805-1-git-send-email-hayeswang@realtek.com>
 <1367546485-1619-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver@neukum.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367546485-1619-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 03, 2013 at 10:01:25AM +0800, Hayes Wang wrote:
> Add new driver for supporting Realtek RTL8152 Based USB 2.0 Ethernet Adapters
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>

You removed the wording I had questions about last time, does that mean
the previous wording was not correct, or that you no longer are
publicising the fact that this driver reads on some patents that you
own?

You also failed to answer my previous questions, why?

greg k-h
