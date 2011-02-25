From: David Miller <davem@davemloft.net>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 11:20:19 -0800 (PST)
Message-ID: <20110225.112019.48513284.davem@davemloft.net>
References: <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
	<20110225125644.GA9763@canuck.infradead.org>
	<1298661495.14113.152.camel@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@infradead.org, therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55840
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753076Ab1BYTTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 14:19:43 -0500
In-Reply-To: <1298661495.14113.152.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 25 Feb 2011 11:18:15 -0800

> and that was with now ancient RHEL5.4 bits...  yes, there is a bit of
> apples, oranges and kumquats but still, I am wondering if this didn't
> also "work around" some internal BIND scaling issues as well.

I think this is fundamentally a bind problem as well.
