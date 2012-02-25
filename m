From: Jesper Nilsson <jesper@jni.nu>
Subject: Re: [PATCH 02/12] cris/eth_v10: check given MAC address, if invalid
 return -EADDRNOTAVAIL
Date: Sat, 25 Feb 2012 18:18:06 +0100
Message-ID: <20120225171805.GB16481@jni.nu>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
 <1330099282-4588-3-git-send-email-danny.kukawka@bisect.de>
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
In-Reply-To: <1330099282-4588-3-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 24, 2012 at 05:01:12PM +0100, Danny Kukawka wrote:
> Check if given address is valid in .ndo_set_mac_address, if
> invalid return -EADDRNOTAVAIL as eth_mac_addr() already does
> if is_valid_ether_addr() fails.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

/^JN - Jesper Nilsson
--
                  Jesper Nilsson -- jesper_at_jni.nu
