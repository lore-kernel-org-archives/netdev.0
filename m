From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BNX2 MIPS06 firmware in tree is 6.2.1, driver wants 6.2.3
Date: Tue, 03 Jul 2012 11:30:52 +0200
Message-ID: <1341307852.2583.123.camel@edumazet-glaptop>
References: <4FF2B263.4080000@linx.net>
	 <1341306334.2583.81.camel@edumazet-glaptop>  <4FF2B64A.5020002@linx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Anthony G. Basile" <basile@virtual.dyc.edu>
To: Tony Vroon <tony@linx.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FF2B64A.5020002@linx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-03 at 10:07 +0100, Tony Vroon wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 03/07/12 10:05, Eric Dumazet wrote:
> > You're supposed to upgrade firmware blobs on your own.
> 
> But the firmware is in the kernel tree still, should the outdated
> files be removed?

I believe firmware/README.AddingFirmware contains the rationale.
