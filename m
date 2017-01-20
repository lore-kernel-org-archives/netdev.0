From: Mark Greer <mgreer@animalcreek.com>
Subject: Re: [PATCH v3 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt
 IO voltage
Date: Fri, 20 Jan 2017 11:37:44 -0700
Message-ID: <20170120183744.GA9749@animalcreek.com>
References: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
 <1482380314-16440-2-git-send-email-geoff@kuvee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, lauro.venancio@openbossa.org,
        aloisio.almeida@openbossa.org, sameo@linux.intel.com,
        robh+dt@kernel.org, mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        justin@kuvee.com
To: Geoff Lansberry <geoff@kuvee.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1482380314-16440-2-git-send-email-geoff@kuvee.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 11:18:33PM -0500, Geoff Lansberry wrote:
> The TRF7970A has configuration options for supporting hardware designs
> with 1.8 Volt or 3.3 Volt IO.   This commit adds a device tree option,
> using a fixed regulator binding, for setting the io voltage to match
> the hardware configuration. If no option is supplied it defaults to
> 3.3 volt configuration.
> 
> Signed-off-by: Geoff Lansberry <geoff@kuvee.com>
> ---
>  .../devicetree/bindings/net/nfc/trf7970a.txt       |  2 ++
>  drivers/nfc/trf7970a.c                             | 26 +++++++++++++++++++++-

Acked-by: Mark Greer <mgreer@animalcreek.com>
