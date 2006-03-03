From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.16-rc5-mm2: IPW_QOS: two remarks
Date: Fri, 3 Mar 2006 16:26:42 +0100
Message-ID: <20060303152641.GR9295@stusta.de>
References: <20060303045651.1f3b55ec.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linville@tuxdriver.com,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751463AbWCCP0n@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>,
	Andreas Happe <andreashappe@snikt.net>
Content-Disposition: inline
In-Reply-To: <20060303045651.1f3b55ec.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 03, 2006 at 04:56:51AM -0800, Andrew Morton wrote:
>...
> Changes since 2.6.16-rc5-mm1:
>...
>  git-netdev-all.patch
>...
>  git trees
>...

Two remarks regarding the new IPW_QOS option:
- it should be named IPW2200_QOS (similar to the other IPW2200_* 
  options)
- please add a help text

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
