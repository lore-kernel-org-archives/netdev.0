From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH]drivers:isdn:istream.c Fix typo pice to piece
Date: Tue, 1 Mar 2011 15:21:24 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1103011521160.32580@pobox.suse.cz>
References: <1298269881-2754-1-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298269881-2754-1-git-send-email-justinmattock@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 20 Feb 2011, Justin P. Mattock wrote:

> The below patch changes a typo "pice" to "piece"
> 
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
> 
> ---
>  drivers/isdn/hardware/eicon/istream.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/isdn/hardware/eicon/istream.c b/drivers/isdn/hardware/eicon/istream.c
> index 18f8798..7bd5baa 100644
> --- a/drivers/isdn/hardware/eicon/istream.c
> +++ b/drivers/isdn/hardware/eicon/istream.c
> @@ -62,7 +62,7 @@ void diva_xdi_provide_istream_info (ADAPTER* a,
>    stream interface.
>    If synchronous service was requested, then function
>    does return amount of data written to stream.
> -  'final' does indicate that pice of data to be written is
> +  'final' does indicate that piece of data to be written is
>    final part of frame (necessary only by structured datatransfer)
>    return  0 if zero lengh packet was written
>    return -1 if stream is full

Applied.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
