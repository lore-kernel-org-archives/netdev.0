From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [RFT] bridge: eliminate port_check workqueue
Date: Thu, 22 Feb 2007 00:58:24 +0300
Message-ID: <20070221215824.GA6461@tv-sign.ru>
References: <20070220221941.GA707@tv-sign.ru> <20070220162434.72d3ad7b@freekitty> <20070221082345.GB1662@ff.dom.local> <20070221142342.GB134@tv-sign.ru> <20070221105555.4d1b40a6@freekitty> <20070221200916.GA145@tv-sign.ru> <20070221131927.07328dca@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.screens.ru ([213.234.233.54]:52278 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751345AbXBUV6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 16:58:25 -0500
Content-Disposition: inline
In-Reply-To: <20070221131927.07328dca@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/21, Stephen Hemminger wrote:
>
> I would rather put it in a bugfix patchset for 2.6.21 and 2.6.20-stable

OK. Even better. Could you also remove br_private.h:BR_PORT_DEBOUNCE then?

Oleg.

