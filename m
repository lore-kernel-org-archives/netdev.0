From: Olaf Hering <olh@suse.de>
Subject: Re: tg3 access hangs on system shutdown with 2.6.11-rc5, tg3_stop_block timed out
Date: Mon, 28 Feb 2005 22:39:05 +0100
Message-ID: <20050228213905.GA20109@suse.de>
References: <B1508D50A0692F42B217C22C02D84972020F3DD2@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@oss.sgi.com
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3DD2@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Mon, Feb 28, Michael Chan wrote:

> The 5704S changes in 2.6.11-rc4 are mainly related to serdes link-up and tx
> signal. I don't see how those changes can cause a hang or the tg3_stop_block
> error. The stack trace did not show any tg3 function calls. Can you narrow it
> down further to a specific patch that is causing the problem?

The blades are currently busy with other testing for the rest of the
week. I ran 2.6.11-rc kernels since a while and it did not happen until
very recently.
