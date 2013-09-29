From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v5] IPv6 NAT: Do not drop DNATed 6to4/6rd packets
Date: Sat, 28 Sep 2013 17:24:28 -0700
Message-ID: <1380414268.11373.3.camel@joe-AO722>
References: <1379963485.3575.53.camel@joe-AO722>
	 <1379966659-28838-1-git-send-email-catab@embedromix.ro>
	 <20130924213606.GB4446@order.stressinduktion.org>
	 <20130928.155750.1130089685321379918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, catab@embedromix.ro,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0101.hostedemail.com ([216.40.44.101]:48482 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755214Ab3I2AYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 20:24:32 -0400
In-Reply-To: <20130928.155750.1130089685321379918.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-28 at 15:57 -0400, David Miller wrote:
> Applied, but Catalin please strictly refer to changes in the following
> precise format:
> 
>         commit $SHA1_ID ("Commit message header line text")
> 
> Because SHA1_IDs are ambiguous, especially when the change in question
> is backported into various -stable branches.

There are now enough commits that using only
8 byte SHA1 IDs generates some collisions so
please use 12 bytes or so of the SHA1.
