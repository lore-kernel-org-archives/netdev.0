From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat, 5 Jan 2008 19:43:17 -0600
Message-ID: <20080105194317.444b49c4@vader.jdub.homelinux.org>
References: <1199526609-12290-1-git-send-email-sr@denx.de>
	<1199528388.7291.55.camel@pasglop>
	<200801051338.17957.sr@denx.de>
	<1199566386.7291.58.camel@pasglop>
	<20080105154805.118eb3d1@vader.jdub.homelinux.org>
	<1199570068.7291.65.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:40997 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259AbYAFBnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 20:43:24 -0500
Received: by py-out-1112.google.com with SMTP id u52so11851920pyb.10
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2008 17:43:23 -0800 (PST)
In-Reply-To: <1199570068.7291.65.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 06 Jan 2008 08:54:28 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> On Sat, 2008-01-05 at 15:48 -0600, Josh Boyer wrote:
> > No need for a defconfig update patch.  Paul or I usually do a general
> > defconfig update for most boards before the next kernel version.  This
> > will get picked up then.
> 
> Will it ? I think the defconfigs will stick to the old value.

Put another way, if Kconfig doesn't update it automagically, I'll be
sure to do it myself. :)

josh
