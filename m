From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.10-rc2] 3c59x: reload EEPROM values at rmmod for needy cards
Date: Wed, 17 Nov 2004 20:21:59 -0500
Message-ID: <20041118012155.GA22765@tuxdriver.com>
References: <20041117160122.A4824@tuxdriver.com> <20041117134425.62034944.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041117134425.62034944.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 17, 2004 at 01:44:25PM -0800, Andrew Morton wrote:
> "John W. Linville" <linville@tuxdriver.com> wrote:
> >
> > 3c905 cards need an additional bit unmasked in the reset at rmmod or
> > else they don't get reinitialized properly when the driver is reloaded.
> 
> This has been in -mm kernels since you first sent it out.  I'm intending to
> hold off until post-2.6.10 so we get a full kernel cycle for any problems
> to get shaken out.

Cool...someone was asking for it in netdev-2.[46], and Jeff didn't
have it.  That is what provoked the resend.

Thanks for the update!

John
-- 
John W. Linville
linville@tuxdriver.com
