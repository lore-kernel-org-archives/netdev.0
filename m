From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patches] 2.6.0-test9 - r8169 DMA API conversion
Date: Wed, 19 Nov 2003 20:36:52 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBC1AB4.9010503@pobox.com>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com> <20031118135848.A2451@electric-eye.fr.zoreil.com> <3FBBA76B.4070606@pobox.com> <20031120010056.A19444@electric-eye.fr.zoreil.com> <3FBC05FB.2020409@mcve.com> <20031120014550.A22377@electric-eye.fr.zoreil.com> <3FBC11F2.5080805@mcve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Brad House <brad_mssw@gentoo.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad@mcve.com>
In-Reply-To: <3FBC11F2.5080805@mcve.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Brad House wrote:
> any reason why it's not against the v1.6 ?
> the current driver is missing support for the
> 8110S chip (or at least it doesn't seem to work at all),
> so you're cutting out all the chips on the mobos out there.
> Haven't looked to see if it's just a PCI ID or other functionality,
> but since the V1.2 is from realtek that's in the official
> kernel, it would make sense to use the 1.6 patch....
> 
> I suppose I could do it, but it would take me much
> more time simply because I'm not familiar with the
> changes you're making.


He's doing the work, and he included 1.6 in his list of changes... looks 
like everybody will be happy :)

	Jeff
