From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: pull request: wireless-2.6 2008-08-01
Date: Sat, 2 Aug 2008 07:42:37 +0200
Message-ID: <200808020742.37575.IvDoorn@gmail.com>
References: <20080801205830.GA10071@tuxdriver.com> <20080801.221604.149076257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:39479 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbYHBFTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 01:19:54 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1463976ika.5
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2008 22:19:52 -0700 (PDT)
In-Reply-To: <20080801.221604.149076257.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 02 August 2008, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Fri, 1 Aug 2008 16:58:30 -0400
> 
> > Another big batch of wireless fixes for 2.6.27.  The ath5k series is
> > more than fixes, but I included it because it enables new ath5k
> > hardware.  (The ath5k.h changes in particular are documentation cleanups
> > for registers based on info gleaned from the newly posted ath9k driver.)
> > The others patches are fixes, some more obvious than others. :-)
> > 
> > Let me know if there are any problems!
> 
> Pulled and pushed out to net-2.6 on kernel.org
> 
> If someone could fix up this warning I'd appreciate it:
> 
> drivers/net/wireless/rt2x00/rt73usb.c: In function 'rt73usb_load_firmware':
> drivers/net/wireless/rt2x00/rt73usb.c:916: warning: passing argument 5 of 'rt2x00usb_vendor_request_large_buff' discards qualifiers from pointer target type

Patch coming up in a few minutes. :)

Ivo
