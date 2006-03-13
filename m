From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [2.6 patch] hostap_ap.c:hostap_add_sta(): inconsequent NULL checking
Date: Sun, 12 Mar 2006 17:23:41 -0800
Message-ID: <20060313012341.GV9383@jm.kir.nu>
References: <20060310191026.GS21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hostap@shmoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751750AbWCMB0y@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060310191026.GS21864@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2006 at 08:10:26PM +0100, Adrian Bunk wrote:
> The Coverity checker spotted this inconsequent NULL checking 
> (unconditionally dereferencing directly after checking for NULL
> isn't a good idea).

Thanks! Added to my queue for wireless-2.6.

-- 
Jouni Malinen                                            PGP id EFC895FA
