From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] fix bridge <-> ATM compile error
Date: Sun, 20 Mar 2005 00:04:58 +0100
Message-ID: <20050319230458.GB18495@stusta.de>
References: <20050316181532.GA3251@stusta.de> <200503172036.j2HKadfm000732@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, bridge@osdl.org,
        linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: chas3@users.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200503172036.j2HKadfm000732@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 17, 2005 at 03:36:40PM -0500, chas williams - CONTRACTOR wrote:
> In message <20050316181532.GA3251@stusta.de>,Adrian Bunk writes:
> >Letting CONFIG_BRIDGE depend on CONFIG_ATM doesn't sound like a good 
> >idea, since I doubt all people using the Bridge code require ATM 
> >support.
> 
> how about the following?
>...

Looks good.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
