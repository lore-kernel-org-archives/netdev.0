From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [2.6 patch] fix the "QoS and/or fair queueing" menu
Date: Mon, 31 Oct 2005 14:27:30 +0100
Message-ID: <20051031132729.GK23537@postel.suug.ch>
References: <Pine.LNX.4.61.0510280902470.6910@yvahk01.tjqt.qr> <20051031102621.GF8009@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932443AbVJaN1K@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20051031102621.GF8009@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Adrian Bunk <bunk@stusta.de> 2005-10-31 11:26
> This patch adjust some dependencies in net/sched/Kconfig for getting all 
> options that belong there under "QoS and/or fair queueing".
> 
> There is no actual semantic change in any dependency, the additional 
> dependencies are added for helping kconfig to figure out what belongs to 
> that menu.

Please hold on, I'm reworking the classification menu.
