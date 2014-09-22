From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] be2net: patch set
Date: Mon, 22 Sep 2014 15:01:33 -0400 (EDT)
Message-ID: <20140922.150133.537343037610956008.davem@davemloft.net>
References: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879AbaIVTBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 15:01:36 -0400
In-Reply-To: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 19 Sep 2014 15:46:50 +0530

> Patches 1 and 2 fix sparse warnings (static declaration needed and endian
> declaration needed) introduced by the earlier patch set.
> 
> Patches 3 and 4 add 20G/40G speed reporting via ethtool for the Skyhawk-R
> chip.
> 
> Patches 5 to 12 fix various style issues and checkpatch warnings in the
> driver such as:
> 	- removing unnecessary return statements in void routines
> 	- adding needed blank lines after a declaration block
> 	- deleting multiple blank lines
> 	- inserting a blank line after a function/struct definition
> 	- removing space after typecast
> 	- fixing multiple assignments on a single line
> 	- fixing alignment on a line wrap

Series applied, thank you.
