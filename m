From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] Documentation: networking: dmfe.txt: Remove the
 maintainer of orphan filesystem
Date: Tue, 30 Aug 2011 14:39:31 -0700
Message-ID: <20110830143931.b4ea10be.rdunlap@xenotime.net>
References: <1314718437-5794-1-git-send-email-marcos.mage@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org
To: Marcos Paulo de Souza <marcos.mage@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1314718437-5794-1-git-send-email-marcos.mage@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Aug 2011 12:33:57 -0300 Marcos Paulo de Souza wrote:

> The dmfe module is a orphan driver, and with this was removed the maintainer
> of the documentation.
> 
> Signed-off-by: Marcos Paulo de Souza <marcos.mage@gmail.com>

Applied, thanks.


> ---
>  Documentation/networking/dmfe.txt |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/networking/dmfe.txt b/Documentation/networking/dmfe.txt
> index 8006c22..25320bf 100644
> --- a/Documentation/networking/dmfe.txt
> +++ b/Documentation/networking/dmfe.txt
> @@ -1,3 +1,5 @@
> +Note: This driver doesn't have a maintainer.
> +
>  Davicom DM9102(A)/DM9132/DM9801 fast ethernet driver for Linux.
>  
>  This program is free software; you can redistribute it and/or
> @@ -55,7 +57,6 @@ Test and make sure PCI latency is now correct for all cases.
>  Authors:
>  
>  Sten Wang <sten_wang@davicom.com.tw >   : Original Author
> -Tobias Ringstrom <tori@unhappy.mine.nu> : Current Maintainer
>  
>  Contributors:
>  
> -- 


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
