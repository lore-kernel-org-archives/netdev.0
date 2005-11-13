From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [2.6 patch] rename hostap.c to hostap_main.c
Date: Sun, 13 Nov 2005 08:46:36 -0800
Message-ID: <20051113164636.GB8968@jm.kir.nu>
References: <20051106005343.GF3668@stusta.de> <20051106041543.GC8972@jm.kir.nu> <20051113162745.GM21448@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hostap@shmoo.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, sam@ravnborg.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964932AbVKMQq7@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20051113162745.GM21448@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 13, 2005 at 05:27:45PM +0100, Adrian Bunk wrote:

> There's no other change.
> 
> If you agree, Jeff might be able to do the
> 
>   mv drivers/net/wireless/hostap/hostap.c \
>     drivers/net/wireless/hostap/hostap_main.c
> 
> plus applying the patch below.

OK, I'm okay with that change.

-- 
Jouni Malinen                                            PGP id EFC895FA
