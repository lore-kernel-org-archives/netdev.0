From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [2.6 patch] schedule SHAPER for removal
Date: Thu, 19 Jan 2006 16:57:22 -0500
Message-ID: <20060119215722.GO16285@kvack.org>
References: <20060119021150.GC19398@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030329AbWASWCS@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060119021150.GC19398@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2006 at 03:11:50AM +0100, Adrian Bunk wrote:
> +What:   Traffic Shaper (CONFIG_SHAPER)
> +When:   July 2006
> +Why:    obsoleted by the code in net/sched/
> +Who:    Adrian Bunk <bunk@stusta.de

This length of obsolete cycles is way too short -- it's not even enough 
time for a single release of a distro to ship with the feature marked as 
obsolete.

		-ben
