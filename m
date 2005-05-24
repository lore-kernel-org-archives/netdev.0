From: Pavel Machek <pavel@suse.cz>
Subject: Re: [0/5] Improvements to the ieee80211 layer
Date: Tue, 24 May 2005 20:52:41 +0200
Message-ID: <20050524185241.GB2470@elf.ucw.cz>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261375AbVEXSxE@vger.kernel.org>
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> The ieee80211 layer, now present in -mm, lacks many important features
> (actually it's just a part of the ipw2100/ipw2200 driver; these cards do
> a lot of the processing in the hardware/firmware and thus the layer
> currently can not be used for simpler devices).
> 
> This is the first series of patches that try to convert it to a generic
> IEEE 802.11 layer, usable for most of today's wireless cards.

Are they against -rc4-mm2?

Would it be possible to put agregate patch on the web somewhere (or
git tree?). I would certainly be easier to test....
								Pavel
