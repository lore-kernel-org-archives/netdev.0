From: Per Liden <per.liden@ericsson.com>
Subject: Re: [2.6 patch] net/tipc/: possible cleanups
Date: Tue, 7 Feb 2006 10:45:02 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0602071043550.15267@ulinpc219.uab.ericsson.se>
References: <20060204011002.GZ4408@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964830AbWBGJuP@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060204011002.GZ4408@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 4 Feb 2006, Adrian Bunk wrote:

> This patch contains the following possible cleanups:
> - make needlessly global code static

Good catch.

> - #if 0 the following unused global functions:
>   - name_table.c: tipc_nametbl_print()
>   - name_table.c: tipc_nametbl_dump()
>   - net.c: tipc_net_next_node()

Thanks! I'll apply this to my tree.

/Per
