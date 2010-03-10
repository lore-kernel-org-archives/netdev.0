From: David Miller <davem@davemloft.net>
Subject: Re: When best to submit patches with small changes in multiple
 files?
Date: Wed, 10 Mar 2010 07:34:48 -0800 (PST)
Message-ID: <20100310.073448.27419654.davem@davemloft.net>
References: <201003100449.12952.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: elendil@planet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53859
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756732Ab0CJPe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:34:28 -0500
In-Reply-To: <201003100449.12952.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frans Pop <elendil@planet.nl>
Date: Wed, 10 Mar 2010 04:49:12 +0100

> I have patches prepared to remove trailing spaces from kernel messages 
> for ./net and ./drivers/net (including wireless).
> 
> In total 15 patches with
>    81 files changed, 351 insertions(+), 351 deletions(-)
> 
> When would be the best time to submit:
> - now, to be included in .34
> - now, for -next
> - any time
> - near beginning of merge window (rebased against netdev-next)
> - not at all ;-)

Later, for -next.  Submit them say in a week or two.
