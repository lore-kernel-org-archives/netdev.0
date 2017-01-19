From: Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
Subject: Re: [PATCH v3 1/3] NFC: trf7970a: add device tree option for 27MHz
 clock
Date: Thu, 19 Jan 2017 16:35:23 -0700
Message-ID: <20170119233523.GA30311@animalcreek.com>
References: <1482380314-16440-1-git-send-email-geoff@kuvee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
        aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org
To: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1482380314-16440-1-git-send-email-geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 11:18:32PM -0500, Geoff Lansberry wrote:
> The TRF7970A has configuration options to support hardware designs
> which use a 27.12MHz clock. This commit adds a device tree option
> 'clock-frequency' to support configuring the this chip for default
> 13.56MHz clock or the optional 27.12MHz clock.
> 
> Signed-off-by: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
> ---

Acked-by: Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>
