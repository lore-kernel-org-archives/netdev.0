From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] ptp: feature enhancements
Date: Wed, 28 Sep 2011 04:17:30 -0400 (EDT)
Message-ID: <20110928.041730.1317347250549344077.davem@davemloft.net>
References: <cover.1316518332.git.richard.cochran@omicron.at>
	<20110926.160443.1205173553442138535.davem@davemloft.net>
	<20110928080023.GB6670@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab1I1IRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 04:17:34 -0400
In-Reply-To: <20110928080023.GB6670@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 28 Sep 2011 10:00:24 +0200

> On Mon, Sep 26, 2011 at 04:04:43PM -0400, David Miller wrote:
>> Could you please add a test at the point where we pull in the
>> ->tx_type value from the user, to make sure it is one of the
>> validly defined HWTSTAMP_TX_FOO values?
> 
> Okay, will do. Any chance of getting the bug fixes in for 3.1?

I plan to try to get them into the next round.
