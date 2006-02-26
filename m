From: Diego Calleja <diegocg@gmail.com>
Subject: Re: [2.6 patch] make UNIX a bool
Date: Sun, 26 Feb 2006 19:19:04 +0100
Message-ID: <20060226191904.974eea0e.diegocg@gmail.com>
References: <20060225160150.GX3674@stusta.de>
	<44009024.5050105@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bunk@stusta.de, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751376AbWBZSWJ@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <44009024.5050105@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El Sat, 25 Feb 2006 09:13:08 -0800,
Stephen Hemminger <shemminger@osdl.org> escribi=F3:

> Why? You can build unix domain sockets as a loadable module and
> it runs fine (or it did last I tried). Whether that makes sense from =
a=20

I've been running with CONFIG_UNIX=3Dm since the dawn of time and every=
thing
seems to work - not that I care if it's disabled, I just wanted to
confirm that it works.
