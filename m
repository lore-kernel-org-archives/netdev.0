From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] ieee802154/adf7242: fix memory leak of firmware
Date: Fri, 8 Apr 2016 10:34:16 -0700
Message-ID: <F14084BA-6B7A-400C-A90F-A202C6E6848A@holtmann.org>
References: <1460027764-27428-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	Alexander Aring <aar@pengutronix.de>,
	linux-kernel@vger.kernel.org, linux-wpan@vger.kernel.org,
	netdev@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460027764-27428-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sudip,

> If the firmware upload or the firmware verification fails then we
> printed the error message and exited but we missed releasing the
> firmware.
> 
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
> ---
> drivers/net/ieee802154/adf7242.c | 2 ++
> 1 file changed, 2 insertions(+)

patch has been applied to bluetooth-next tree.

Regards

Marcel
