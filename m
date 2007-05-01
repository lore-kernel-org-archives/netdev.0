From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 23/36] Use menuconfig objects II - netdev/wan
Date: Tue, 01 May 2007 22:04:37 +0200
Message-ID: <m37irsux7u.fsf@maximus.localdomain>
References: <Pine.LNX.4.61.0704301225060.29151@yvahk01.tjqt.qr>
	<Pine.LNX.4.61.0704301345101.29151@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753564AbXEAUEl@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.61.0704301345101.29151@yvahk01.tjqt.qr> (Jan Engelhardt's message of "Mon, 30 Apr 2007 13:45:51 +0200 (MEST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt <jengelh@linux01.gwdg.de> writes:

> Change Kconfig objects from "menu, config" into "menuconfig" so
> that the user can disable the whole feature without having to
> enter the menu first.
>
> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
>
> ---
>  drivers/net/wan/Kconfig |   34 +++++++++++++++-------------------

Looks good.
-- 
Krzysztof Halasa
