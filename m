From: Jesper Nilsson <jesper@jni.nu>
Subject: Re: [PATCH 3/8] cris/eth_v10: use dev_set_mac_address() instead of
 e100_set_mac_address()
Date: Thu, 1 Mar 2012 10:33:40 +0100
Message-ID: <20120301093339.GG16481@jni.nu>
References: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
 <1330530176-24952-4-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Javier Martinez Canillas <martinez.javier@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330530176-24952-4-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 29, 2012 at 04:42:51PM +0100, Danny Kukawka wrote:
> Use dev_set_mac_address() instead of e100_set_mac_address() directly
> to get validation checks for free.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

> ---
>  drivers/net/cris/eth_v10.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)


/^JN - Jesper Nilsson
