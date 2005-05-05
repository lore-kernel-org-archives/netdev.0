From: Andi Kleen <ak@muc.de>
Subject: Re: Mystery packet killing tg3
Date: 5 May 2005 21:24:05 +0200
Message-ID: <20050505192405.GF24386@muc.de>
References: <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de> <427A5363.2080703@pantasys.com> <20050505180609.GB24386@muc.de> <427A6426.40104@pantasys.com> <20050505183144.GD24386@muc.de> <427A6898.4070804@pantasys.com> <20050505185635.GE24386@muc.de> <427A6DB7.10404@pantasys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 5 May 2005 21:24:05 +0200
To: Peter Buckingham <peter@pantasys.com>
Content-Disposition: inline
In-Reply-To: <427A6DB7.10404@pantasys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >The dmesg looks similar to the previous one from the IOMMU
> >code perspective.
> 
> it actually looks like it's configure correctly now (at least from 
> agp-gart messages), before we were getting errors. i guess the bios guys 
> finally got it right ;-)

No, it is still broken, the kernel fixed it up. Look at the early
messages. It was too small (32MB)

-Andi
