From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 2/4] staging: rtl8712: Rename local variable
Date: Sun, 7 Feb 2016 19:51:19 -0800
Message-ID: <20160208035119.GA31656@kroah.com>
References: <1448473362-12524-1-git-send-email-mukadr@gmail.com>
 <1448473362-12524-3-git-send-email-mukadr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Mauro Dreissig <mukadr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:57245 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbcBHDvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 22:51:20 -0500
Content-Disposition: inline
In-Reply-To: <1448473362-12524-3-git-send-email-mukadr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2015 at 03:42:40PM -0200, Mauro Dreissig wrote:
> Renames all instances of struct _adapter to adapter in rtl871x_ioctl_rtl.c,
> avoiding camel case.
> 
> Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
> ---
>  drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 86 ++++++++++++++---------------
>  1 file changed, 43 insertions(+), 43 deletions(-)

Two patches with the identical subject line isn't good, I can't accept
these, please fix up.

thanks,

greg k-h
