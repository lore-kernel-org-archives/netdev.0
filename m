From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 0/6] be2net patch set
Date: Tue, 27 Aug 2013 15:57:31 -0400 (EDT)
Message-ID: <20130827.155731.2077033463857211702.davem@davemloft.net>
References: <1377602855-13920-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab3H0T5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 15:57:33 -0400
In-Reply-To: <1377602855-13920-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 27 Aug 2013 16:57:29 +0530

> This series includes code refactoring patches needed to cleanly implement
> ethtool set-channels features. Pls apply. Thanks.
> 
> Sathya Perla (5):
>   be2net: use EQ_CREATEv2 for SH-R
>   be2net: refactor be_get_resources() code
>   be2net: Fix be_cmd_if_create() to use MBOX if MCCQ is not created
>   be2net: refactor be_setup() to consolidate queue creation routines
>   be2net: implement ethtool set/get_channel hooks
> 
> Vasundhara Volam (1):
>   be2net: Fixup profile management routines

Series applied, thanks.
