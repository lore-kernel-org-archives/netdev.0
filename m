From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso: Use static attribute groups for sysfs entry
Date: Thu, 05 Feb 2015 00:33:52 -0800 (PST)
Message-ID: <20150205.003352.272872759054571950.davem@davemloft.net>
References: <1423057173-6981-1-git-send-email-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: tiwai@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756643AbbBEIdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:33:53 -0500
In-Reply-To: <1423057173-6981-1-git-send-email-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takashi Iwai <tiwai@suse.de>
Date: Wed,  4 Feb 2015 14:39:33 +0100

> Pass the static attribute groups and the driver data via
> tty_port_register_device_attr() instead of manual device_create_file()
> and device_remove_file() calls.
> 
> Signed-off-by: Takashi Iwai <tiwai@suse.de>

This does not apply cleanly to the net-next tree, please respin.
