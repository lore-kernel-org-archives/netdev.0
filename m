From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v2 bluetooth-next] cc2520: set the default fifo pin value from platform data
Date: Mon, 10 Aug 2015 21:14:56 -0700
Message-ID: <4DB1C0CA-7453-4763-91E2-F46565E9A649@holtmann.org>
References: <1439260985-5173-1-git-send-email-sdliyong@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkabhadram@gmail.com>,
	Alexander Aring <alex.aring@gmail.com>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sdliyong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439260985-5173-1-git-send-email-sdliyong@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yong,

> When the device tree support is disabled, the fifo_pin is uninitialized,
> this patch will set the fifo_pin value based on platform data
> 
> Signed-off-by: Yong Li <sdliyong@gmail.com>
> ---
> drivers/net/ieee802154/cc2520.c | 1 +
> 1 file changed, 1 insertion(+)

patch has been applied to bluetooth-next tree.

Regards

Marcel
