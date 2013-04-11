From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/11] usbnet: handle link change
Date: Thu, 11 Apr 2013 15:58:07 -0400 (EDT)
Message-ID: <20130411.155807.1568843893021966654.davem@davemloft.net>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
	<1365691240-816-12-git-send-email-ming.lei@canonical.com>
	<CACVXFVNtitJfsKMORPyduEztQHiN1cWcVXWep=ScUNLRwv9W=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, oneukum@suse.de,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: ming.lei@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38643 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710Ab3DKT6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 15:58:10 -0400
In-Reply-To: <CACVXFVNtitJfsKMORPyduEztQHiN1cWcVXWep=ScUNLRwv9W=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <ming.lei@canonical.com>
Date: Thu, 11 Apr 2013 22:52:29 +0800

> On Thu, Apr 11, 2013 at 10:40 PM, Ming Lei <ming.lei@canonical.com> wrote:
>>         dd if=/dev/sda iflag=direct of=/dev/null bs=1M count=500
> 
> Sorry, the above should be:
> 
>         dd if=/dev/sda iflag=direct of=/dev/null bs=1M count=800

I'll fix this up when I apply this patch series.
