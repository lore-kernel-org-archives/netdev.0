From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] pcmcia: remove cs_types.h
Date: Fri, 23 Jul 2010 11:48:16 -0700 (PDT)
Message-ID: <20100723.114816.193692123.davem@davemloft.net>
References: <20100723083726.GA20947@comet.dominikbrodowski.net>
	<1279874305-21191-6-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-ide@vger.kernel.org,
	linux-usb@vger.kernel.org, laforge@gnumonks.org,
	linux-mtd@lists.infradead.org, linux-bluetooth@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-serial@vger.kernel.org
To: linux@dominikbrodowski.net
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <1279874305-21191-6-git-send-email-linux@dominikbrodowski.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Fri, 23 Jul 2010 10:38:25 +0200

> Remove cs_types.h which is no longer needed: Most definitions aren't
> used at all, a few can be made away with, and two remaining definitions
> (typedefs, unfortunatley) may be moved to more specific places.
> 
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

Acked-by: David S. Miller <davem@davemloft.net>
