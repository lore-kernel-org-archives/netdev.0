From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [janitor] remove casts in drivers/net/arm/
Date: Tue, 2 Mar 2004 19:36:04 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040302193604.G12353@flint.arm.linux.org.uk>
References: <20040229142516.3d218ed0.rddunlap@osdl.org> <20040229143436.4bb884ee.rddunlap@osdl.org> <20040302121042.A9931@flint.arm.linux.org.uk> <4044D86C.70709@pobox.com> <20040302110237.0f580736.rddunlap@osdl.org> <4044DB78.7040309@pobox.com> <20040302111700.76c0b381.rddunlap@osdl.org> <4044E07E.8000409@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4044E07E.8000409@pobox.com>; from jgarzik@pobox.com on Tue, Mar 02, 2004 at 02:29:02PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 02, 2004 at 02:29:02PM -0500, Jeff Garzik wrote:
> I wasn't rejecting your patches.
> 
> In fact, I want to apply your cast patches separate from any 
> netdev_priv() cleanup.
> 
> netdev_priv() should be a separate item on the janitor todo list.
> 
> RMK however is free to reject these patches for drivers/net/arm/ of 
> course...

I'm easy - I probably won't look at this until post-2.6.4 anyway.

However, it seems a bit silly to produce two patches changing the
exact same lines when one patch would do.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
