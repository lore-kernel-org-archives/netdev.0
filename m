From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax: remove dead code
Date: Thu, 21 Nov 2013 13:19:33 -0500 (EST)
Message-ID: <20131121.131933.1763933667490268654.davem@davemloft.net>
References: <1385005391-18379-1-git-send-email-michael.opdenacker@free-electrons.com>
	<1385007469.2164.39.camel@joe-AO722>
	<1385018850.14273.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, michael.opdenacker@free-electrons.com,
	inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	wimax@linuxwimax.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab3KUSTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:19:35 -0500
In-Reply-To: <1385018850.14273.0.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 21 Nov 2013 08:27:30 +0100

> On Wed, 2013-11-20 at 20:17 -0800, Joe Perches wrote:
>> On Thu, 2013-11-21 at 04:43 +0100, Michael Opdenacker wrote:
>> > This removes a code line that is between a "return 0;" and an error label.
>> > This code line can never be reached.
>> 
>> Adding Johannes Berg who added this oversight.
> 
> Obviously, sorry about that. I seem to remember deleting *something*
> there (like another error label) but I guess I missed that line.
> 
> Acked-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks.
