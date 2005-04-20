From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [2.6 patch] drivers/net/sk98lin/: possible cleanups
Date: Wed, 20 Apr 2005 09:39:28 +0100
Message-ID: <20050420083928.GA29040@infradead.org>
References: <20050420021526.GB5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mlindner@syskonnect.de, rroesler@syskonnect.de,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261309AbVDTIjs@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050420021526.GB5489@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 20, 2005 at 04:15:26AM +0200, Adrian Bunk wrote:
> This patch contains the following possible cleanups:
> - make needlessly global functions static
> - remove unused code

Not sure it's worth doing much on this, as the driver is beeing
obsoleted by the skge driver.
