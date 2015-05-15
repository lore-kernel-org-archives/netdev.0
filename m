From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Fri, 15 May 2015 12:19:42 -0400 (EDT)
Message-ID: <20150515.121942.697185533705459189.davem@redhat.com>
References: <20150515143506.GA5019@via.ecp.fr>
	<CALx6S35tiLs=RU9t9XriakDgD-66N4F2FKrpQYe6--XhBn=_Ng@mail.gmail.com>
	<20150515155441.GA24669@via.ecp.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753478AbbEOQTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 12:19:47 -0400
In-Reply-To: <20150515155441.GA24669@via.ecp.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 15 May 2015 17:54:41 +0200

> Hi Tom,
> 
> 2015-05-15, 11:27:25 -0400, Tom Herbert wrote:
>> Hi Sabrina,
>> 
>> We returned the checksum value since that may be of interest to the
>> caller at some point.
> 
> Hmm, I thought "we may need that some day" was not a valid argument?

I think Tom's time frame for "some day" is really small and he
should be accomodated.
