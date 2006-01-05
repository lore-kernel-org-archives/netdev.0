From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC: 2.6 patch] remove drivers/net/eepro100.c
Date: Thu, 05 Jan 2006 13:57:07 -0500
Message-ID: <43BD6C03.2080605@pobox.com>
References: <20060105181826.GD12313@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: saw@saw.sw.com.sg, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751893AbWAES5a@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060105181826.GD12313@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch removes the obsolete drivers/net/eepro100.c driver.
> 
> Is there any known problem in e100 still preventing us from removing 
> this driver (it seems noone was able anymore to verify the ARM problem)?

Still waiting to see if e100 in -mm works on ARM.

	Jeff
