From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patches] 2.6.0-test9 - r8169 DMA API conversion
Date: Thu, 20 Nov 2003 01:45:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031120014550.A22377@electric-eye.fr.zoreil.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com> <20031118135848.A2451@electric-eye.fr.zoreil.com> <3FBBA76B.4070606@pobox.com> <20031120010056.A19444@electric-eye.fr.zoreil.com> <3FBC05FB.2020409@mcve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Brad House <brad_mssw@gentoo.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad@mcve.com>
Content-Disposition: inline
In-Reply-To: <3FBC05FB.2020409@mcve.com>; from brad@mcve.com on Wed, Nov 19, 2003 at 07:08:27PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Brad House <brad@mcve.com> :
> Just because I'm way to lazy to actually look, is this
> against the original r8169, or my patch from the v1.6
> driver ??

It is against the original r8169. Once finished, it should look like:
- first cut at dma api conversion (today)
- remaining bits of dma api conversion (tomorrow)
- rx_copybreak (tomorrow)
- your changes (week-end)
- big-endian fixes (week-end)

Each part divided in reasonably small patches to ease the test/review process.

--
Ueimor
