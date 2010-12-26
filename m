From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [patch] USB: cdc_ether: remove unneeded check
Date: Sun, 26 Dec 2010 13:06:22 +0100
Message-ID: <201012261306.22500.oliver@neukum.org>
References: <20101225222341.GS1936@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.name>,
	"Greg Kroah-Hartman" <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:44191 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049Ab0LZME7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Dec 2010 07:04:59 -0500
In-Reply-To: <20101225222341.GS1936@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, 25. Dezember 2010, 23:23:42 schrieb Dan Carpenter:
> We already verified that "dev->udev->actconfig->extralen" was non-zero
> so "len" is non-zero here as well.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
Acked-by: Oliver Neukum <oneukum@suse.de>


