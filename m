From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 00/12] Convert more drivers to ethtool
 set_phys_id
Date: Mon, 04 Apr 2011 13:06:24 -0700 (PDT)
Message-ID: <20110404.130624.63023544.davem@davemloft.net>
References: <20110404184340.604594357@linuxplumber.net>
	<BANLkTimfFPEhr4GozxBZB5Pc-LGXWfGTPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755445Ab1DDUHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:07:01 -0400
In-Reply-To: <BANLkTimfFPEhr4GozxBZB5Pc-LGXWfGTPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 4 Apr 2011 12:53:14 -0700

> On Mon, Apr 4, 2011 at 11:43, Stephen Hemminger <shemminger@vyatta.com> wrote:
>> Did a bunch of the easy drivers to convert.
>>
>>
> 
> I have added patches 3-9 (Intel driver conversions) to my queue of
> patches.  Thanks Stephen.

Careful, Ben's commit to add the interface still isn't in the tree.

He needs to respin his patch set based upon feedback that came in
the other day.
