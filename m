From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] [0/12] pasemi_mac updates for 2.6.25 + DMA channel
	management library
Date: Wed, 28 Nov 2007 20:59:20 -0600
Message-ID: <20071129025920.GN17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:36954 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757942AbXK2C4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:56:09 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2007 at 08:54:10PM -0600, Olof Johansson wrote:

> The patches are:
[...]

I got the order wrong above, the actual one is:

1/12 pasemi_mac: RX/TX ring management cleanup
2/12 pasemi_mac: Move register definitions to include/asm-powerpc
3/12 pasemi: DMA engine management library
4/12 pasemi_mac: Convert to new dma library
5/12 pasemi_mac: performance tweaks
6/12 pasemi_mac: Fix TX cleaning
7/12 pasemi_mac: Improve RX interrupt mitigation
8/12 pasemi_mac: Software-based LRO support
9/12 pasemi_mac: SKB unmap optimization
10/12 pasemi_mac: Remove SKB copy/recycle logic
11/12 pasemi_mac: Print warning when not attaching to a PHY
12/12 pasemi_mac: Don't enable RX/TX without a link (if possible)

