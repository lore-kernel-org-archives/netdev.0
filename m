From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH] NFC: remove commented out Makefile line
Date: Sun, 12 May 2013 23:39:47 +0200
Message-ID: <1368394787.9190.0.camel@zurbaran>
References: <1368393684.1350.16.camel@x61.thuisdomein>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-nfc@ml01.01.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368393684.1350.16.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

On Sun, 2013-05-12 at 23:21 +0200, Paul Bolle wrote:
> The Kconfig symbol NFC_LLCP was removed in commit 30cc458765 ("NFC: Move
> LLCP code to the NFC top level diirectory"). But the reference to its
> macro in this Makefile was only commented out. Remove it now.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> Untested.
> 
>  net/nfc/Makefile | 1 -
>  1 file changed, 1 deletion(-)
Applied to my nfc-fixes tree, thanks.

Cheers,
Samuel.
