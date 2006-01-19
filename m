From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [2.6 patch] schedule SHAPER for removal
Date: Thu, 19 Jan 2006 21:18:57 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0601192118070.26558@yvahk01.tjqt.qr>
References: <20060119021150.GC19398@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161413AbWASUU5@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060119021150.GC19398@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>Subject: [2.6 patch] schedule SHAPER for removal

Replaced by what; the QoS subsystem?


> config SHAPER
>-	tristate "Traffic Shaper (EXPERIMENTAL)"
>+	tristate "Traffic Shaper (OBSOLETE)"
> 	depends on EXPERIMENTAL


Jan Engelhardt
-- 
| Alphagate Systems, http://alphagate.hopto.org/
| jengelh's site, http://jengelh.hopto.org/
