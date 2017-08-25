From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] cdc_ncm: flag the ublox TOBY-L4 as wwan
Date: Fri, 25 Aug 2017 06:22:36 -0700
Message-ID: <20170825132236.GB16203@kroah.com>
References: <20170825125946.12812-1-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver@neukum.org, davem@davemloft.net, stefano.godeas@u-blox.com,
        marco.demarco@u-blox.com, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825125946.12812-1-aleksander@aleksander.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2017 at 02:59:46PM +0200, Aleksander Morgado wrote:
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
> ---
>  drivers/net/usb/cdc_ncm.c | 7 +++++++
>  1 file changed, 7 insertions(+)

Personally, I require patches to have changelog texts in them...
