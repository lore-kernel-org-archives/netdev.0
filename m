From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.9 9/11] r8169: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 15:59:38 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020155938.T8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com> <20041020142858.L8775@tuxdriver.com> <Pine.LNX.4.61.0410201629120.6918@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Linux kernel <linux-kernel@vger.kernel.org>,
        jgarzik@pobox.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Richard B. Johnson" <root@chaos.analogic.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0410201629120.6918@chaos.analogic.com>; from root@chaos.analogic.com on Wed, Oct 20, 2004 at 04:34:45PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2004 at 04:34:45PM -0400, Richard B. Johnson wrote:
> 
> This makes warning error about :
> 
> Warning: could not find versions for .tmp_versions/r8169.mod
> 
> Do I have to enable something in .config (like CONFIG_MODVERSIONS)?
> If so, how does one make this transparent, to get rid of the
> warning if CONFIG_MODVERSIONS is not set?

Odd...I don't get any such warning, with or without
CONFIG_MODVERSIONS...

MODULE_VERSION is used elsewhere -- do you get that warning
from any other modules?  Was this from a clean build?

Send me your .config, and I'll look into it.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
