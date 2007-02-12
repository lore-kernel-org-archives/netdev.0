From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH][RESPIN] gianfar: Convert network devices to use struct device instead of class_device
Date: Mon, 12 Feb 2007 15:57:16 -0600
Message-ID: <49E3B73B-8C6D-48EC-8852-17DDA2D72A9E@freescale.com>
References: <Pine.LNX.4.64.0702081118090.29779@localhost.localdomain> <45CCE357.3030203@pobox.com> <Pine.LNX.4.64.0702091531090.8491@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:50023 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965396AbXBLV53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 16:57:29 -0500
In-Reply-To: <Pine.LNX.4.64.0702091531090.8491@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 9, 2007, at 15:33, Kumar Gala wrote:

> Convert network devices to use struct device instead of  
> class_device.  Greg
> missed this one in his cleanup path.
>
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

Acked-by: Andy Fleming <afleming@freescale.com>

Jeff, please get this into 2.6.21.  The current tree doesn't build  
without it!


Andy


