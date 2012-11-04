From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v1 2/5] usbnet: smsc75xx: apply the introduced usbnet_read[write]_cmd_nopm
Date: Sun, 4 Nov 2012 19:19:14 +0800
Message-ID: <CACVXFVMRM7SQZNi+917sD5rOPeWRvW7Gvqj6zAdqfx8GHwcJbg@mail.gmail.com>
References: <1351992594-12818-1-git-send-email-ming.lei@canonical.com>
	<1351992594-12818-3-git-send-email-ming.lei@canonical.com>
	<20121104.015834.655875426096699012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: gregkh@linuxfoundation.org, oneukum@suse.de,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	steve.glendinning@shawell.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38767 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab2KDLTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 06:19:16 -0500
In-Reply-To: <20121104.015834.655875426096699012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 4, 2012 at 1:58 PM, David Miller <davem@davemloft.net> wrote:
>
> This gets rejects, you didn't have your net-next tree uptodate
> enough.

Sorry, I just rebased that on 3.7.0-rc3-next-20121102.

The new patchset which is against the latest net-next has been sent out.

Thanks,
--
Ming Lei
