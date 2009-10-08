From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netlink: fix typo in initialization
Date: Thu, 08 Oct 2009 01:20:43 -0700 (PDT)
Message-ID: <20091008.012043.113325384.davem@davemloft.net>
References: <20091008072323.GA3255@psychotron.lab.eng.brq.redhat.com>
	<20091008.005743.231834593.davem@davemloft.net>
	<20091008080858.GC3255@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755675AbZJHIUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 04:20:47 -0400
In-Reply-To: <20091008080858.GC3255@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 8 Oct 2009 10:08:59 +0200

> Thu, Oct 08, 2009 at 09:57:43AM CEST, davem@davemloft.net wrote:
>>From: Jiri Pirko <jpirko@redhat.com>
>>Date: Thu, 8 Oct 2009 09:23:23 +0200
>>
>>Therefore, this fix probably belongs in net-2.6 and -stable instead
>>of net-next-2.6, right?
> 
> Okay. The patch is applicable on net-2.6 (I presume on -stable too). Feel free
> to apply.

Great, I'll take care of this, thanks.
