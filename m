From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2] USB: cdc: add MBIM extended functional descriptor
 structure
Date: Mon, 17 Mar 2014 16:07:40 -0700
Message-ID: <20140317230740.GA32440@kroah.com>
References: <1394952550-9308-1-git-send-email-benchan@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Greg Suarez <gsuarez@smithmicro.com>
To: Ben Chan <benchan@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394952550-9308-1-git-send-email-benchan@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 15, 2014 at 11:49:09PM -0700, Ben Chan wrote:
> This patch adds the MBIM extended functional descriptor structure
> defined in "Universal Serial Bus Communications Class Subclass
> Specification for Mobile Broadband Interface Model, Revision 1.0,
> Errata-1" published by USB-IF.
> 
> Signed-off-by: Ben Chan <benchan@chromium.org>
> ---
>  include/uapi/linux/usb/cdc.h | 12 ++++++++++++
>  1 file changed, 12 insertions(+)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
