From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 6/6] pcmcia: remove cs_types.h
Date: Fri, 23 Jul 2010 09:27:02 -0400
Message-ID: <20100723132702.GB6678@tuxdriver.com>
References: <20100723083726.GA20947@comet.dominikbrodowski.net>
 <1279874305-21191-6-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-ide@vger.kernel.org,
	linux-usb@vger.kernel.org, laforge@gnumonks.org,
	linux-mtd@lists.infradead.org, linux-bluetooth@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-serial@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1279874305-21191-6-git-send-email-linux@dominikbrodowski.net>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 10:38:25AM +0200, Dominik Brodowski wrote:
> Remove cs_types.h which is no longer needed: Most definitions aren't
> used at all, a few can be made away with, and two remaining definitions
> (typedefs, unfortunatley) may be moved to more specific places.
> 
> CC: netdev@vger.kernel.org
> CC: linux-wireless@vger.kernel.org
> CC: linux-ide@vger.kernel.org
> CC: linux-usb@vger.kernel.org
> CC: laforge@gnumonks.org
> CC: linux-mtd@lists.infradead.org
> CC: linux-bluetooth@vger.kernel.org
> CC: alsa-devel@alsa-project.org
> CC: linux-serial@vger.kernel.org
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

ACK for the drivers/net/wireless bits...

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
