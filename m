From: Adrian Bunk <bunk@fs.tum.de>
Subject: Re: [2.6 patch] atalk compile errors with SYSCTL=n
Date: Thu, 12 Aug 2004 10:47:17 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040812084717.GY26174@fs.tum.de>
References: <20040811224747.GQ26174@fs.tum.de> <20040811170101.69c140b6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@conectiva.com.br, linux-kernel@vger.kernel.org,
	davem@redhat.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268464AbUHLIrY@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040811170101.69c140b6@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Wed, Aug 11, 2004 at 05:01:01PM -0700, Stephen Hemminger wrote:

> I prefer to have the CONFIG stuff in the header file.
> Here is an alternative that rearranges to put all function prototypes in atalk.h
> and stubs if necessary. It gets all the #ifdef CONFIG_ stuff out of the
> .c files.
>...

Compiles and looks good.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
