From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: revert per-vxlan port
Date: Wed, 22 May 2013 15:08:30 -0700 (PDT)
Message-ID: <20130522.150830.1305371698781503084.davem@davemloft.net>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net>
	<OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com>
	<20130520113000.0057ce90@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756513Ab3EVWIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 18:08:31 -0400
In-Reply-To: <20130520113000.0057ce90@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 20 May 2013 11:30:00 -0700

> On Mon, 20 May 2013 14:15:59 -0400
> David Stevens <dlstevens@us.ibm.com> wrote:
> 
>> I think an administrator should have full flexibility to specify
>> the ports and destinations as s/he sees fit and if you don't think
>> that's a useful feature, you don't have to use it; the defaults
>> work fine, too.
> 
> They can do that with neighbour entries.

David, please come to some kind of agreement with Stephen about what
we're going to do about this.

Thank you.
