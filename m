From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove bond_dev from xmit_hash_policy call.
Date: Sat, 24 Oct 2009 07:00:21 -0700 (PDT)
Message-ID: <20091024.070021.162597597.davem@davemloft.net>
References: <4AE1A37F.8010203@gmail.com>
	<20091023140924.GA24611@spaans.fox.local>
	<15659.1256315071@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: spaans@fox-it.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46415
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753507AbZJXN76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:59:58 -0400
In-Reply-To: <15659.1256315071@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 23 Oct 2009 09:24:31 -0700

> Jasper Spaans <spaans@fox-it.com> wrote:
> 
>>Now that the bonding device is no longer used in determining the device to
>>which to send packets, it can be dropped from the argument list of the various
>>xmit_hash_policy calls.
>>
>>Signed-off-by: Jasper Spaans <spaans@fox-it.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks everyone.
