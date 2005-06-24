From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [2.6 patch] drivers/net/ne3210.c: cleanups
Date: Fri, 24 Jun 2005 22:36:04 +0200
Message-ID: <20050624223604.3aec0cb1.khali@linux-fr.org>
References: <20050624200919.GK6656@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263044AbVFXUiU@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050624200919.GK6656@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Adrian,

>  	if (ei_debug > 0)
> -		printk(version);
> +		printk("ne3210 loaded.\n");

No KERN_DEBUG?

Thanks,
-- 
Jean Delvare
