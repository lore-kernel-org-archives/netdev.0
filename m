From: Andrew Morton <akpm@osdl.org>
Subject: Re: [-mm patch] is_broadcast_ether_addr() is still required
Date: Fri, 8 Jul 2005 13:45:43 -0700
Message-ID: <20050708134543.1e5fa440.akpm@osdl.org>
References: <20050708200704.GH3671@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bero@arklinux.org, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, ipw2100-admin@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262893AbVGHUvZ@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050708200704.GH3671@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:
>
> This patch by Bernhard Rosenkraenzer <bero@arklinux.org> is still 
> required to fix the following compile error:

I think this problem is due to my failure to navigate the miasma of Jeff's
git trees.  I need to go in and look at all his branches and work out
what's missing.
