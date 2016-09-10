From: Andreas Noever <andreas.noever@gmail.com>
Subject: Re: [PATCH v6 1/8] thunderbolt: Macro rename
Date: Sun, 11 Sep 2016 01:20:44 +0200
Message-ID: <CAMxnaaW0vBFeUcLg6oC=FuRx3sqStQ4pht2HUzyHqDMtf8oR2g@mail.gmail.com>
References: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com> <1470054233-4309-2-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <gregkh@linuxfoundation.org>,
        Bjorn Helgaas <bhelgaas@google.com>, corbet@lwn.net,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        thunderbolt-linux <thunderbolt-linux@intel.com>,
        "Westerberg, Mika" <mika.westerberg@intel.com>,
        "Winkler, Tomas" <tomas.winkler@intel.com>
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1470054233-4309-2-git-send-email-amir.jer.levy@intel.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 1, 2016 at 2:23 PM, Amir Levy <amir.jer.levy@intel.com> wrote:
> This first patch updates the registers file to
> reflect that it isn't only for Cactus Ridge.
> No functional change intended.
>
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  drivers/thunderbolt/nhi_regs.h | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/thunderbolt/nhi_regs.h b/drivers/thunderbolt/nhi_regs.h
> index 86b996c..75cf069 100644
> --- a/drivers/thunderbolt/nhi_regs.h
> +++ b/drivers/thunderbolt/nhi_regs.h
> @@ -1,11 +1,11 @@
>  /*
> - * Thunderbolt Cactus Ridge driver - NHI registers
> + * Thunderbolt driver - NHI registers
>   *
>   * Copyright (c) 2014 Andreas Noever <andreas.noever@gmail.com>
>   */
>
> -#ifndef DSL3510_REGS_H_
> -#define DSL3510_REGS_H_
> +#ifndef NHI_REGS_H_
> +#define NHI_REGS_H_
>
>  #include <linux/types.h>
>
> --
> 2.7.4
Signed-off-by: Andreas Noever <andreas.noever@gmail.com>
