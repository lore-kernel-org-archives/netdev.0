From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.38.4] mii: add support of pause frames in mii_get_an
Date: Fri, 29 Apr 2011 13:57:45 -0700 (PDT)
Message-ID: <20110429.135745.258121929.davem@davemloft.net>
References: <1303962554.15395.1.camel@artpol-thinkpad>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: artpol84@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303962554.15395.1.camel@artpol-thinkpad>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: artpol <artpol84@gmail.com>
Date: Thu, 28 Apr 2011 10:49:14 +0700

> Add support of pause frames advertise in mii_get_an. This provides all drivers 
> that use mii_ethtool_gset to represent their own and Link partner flow control
> abilities in ethtool.
> 
> Signed-off-by: Artem Polyakov <artpol84@gmail.com>

Applied, thanks.
