From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] pktgen documentation cleanup and samples
Date: Mon, 23 Feb 2015 22:05:47 -0500 (EST)
Message-ID: <20150223.220547.266499126808113896.davem@davemloft.net>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk
To: ben.hutchings@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbBXDFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 22:05:49 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Tue, 24 Feb 2015 02:30:19 +0000

> This series cleans up the pktgen documentation, adds and improves
> the original sample scripts.

Series applied, but I had to fix some trailing whitespace issues
in patch #3, and subsequently apply the rest of the changes using
"patch -l" to make them still apply.

Please check what "git am" does with your patches unless you are
absolutely sure, it screamed at me when I tried to apply this series.
