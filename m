From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sun, 06 Jan 2008 08:54:28 +1100
Message-ID: <1199570068.7291.65.camel@pasglop>
References: <1199526609-12290-1-git-send-email-sr@denx.de>
	 <1199528388.7291.55.camel@pasglop> <200801051338.17957.sr@denx.de>
	 <1199566386.7291.58.camel@pasglop>
	 <20080105154805.118eb3d1@vader.jdub.homelinux.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:44516 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756882AbYAEVyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 16:54:55 -0500
In-Reply-To: <20080105154805.118eb3d1@vader.jdub.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-01-05 at 15:48 -0600, Josh Boyer wrote:
> No need for a defconfig update patch.  Paul or I usually do a general
> defconfig update for most boards before the next kernel version.  This
> will get picked up then.

Will it ? I think the defconfigs will stick to the old value.

Ben.

