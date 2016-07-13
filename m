From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: bluetooth-next 2016-07-13
Date: Wed, 13 Jul 2016 16:06:02 -0700 (PDT)
Message-ID: <20160713.160602.1965210574276689269.davem@davemloft.net>
References: <20160713082540.GA3719@t440s.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160713082540.GA3719-ypHiNAJIRA7/PtFMR13I2A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 13 Jul 2016 11:25:40 +0300

> Here's our main bluetooth-next pull request for the 4.8 kernel:
> 
>  - Fixes and cleanups in 802.15.4 and 6LoWPAN code
>  - Fix out of bounds issue in btmrvl driver
>  - Fixes to Bluetooth socket recvmsg return values
>  - Use crypto_cipher_encrypt_one() instead of crypto_skcipher
>  - Cleanup of Bluetooth connection sysfs interface
>  - New Authentication failure reson code for Disconnected mgmt event
>  - New USB IDs for Atheros, Qualcomm and Intel Bluetooth controllers
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
