From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] v3 ethtool: add ntuple flow specifier
 data to network flow classifier
Date: Mon, 11 Apr 2011 13:21:30 -0700 (PDT)
Message-ID: <20110411.132130.245388032.davem@davemloft.net>
References: <20110409040159.6064.79138.stgit@gitlad.jf.intel.com>
	<1302345512.5282.48.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754239Ab1DKUWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:22:06 -0400
In-Reply-To: <1302345512.5282.48.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 09 Apr 2011 11:38:32 +0100

> On Fri, 2011-04-08 at 21:01 -0700, Alexander Duyck wrote:
>> This change is meant to add an ntuple data extensions to the rx network flow
>> classification specifiers.  The idea is to allow ntuple to be displayed via
>> the network flow classification interface.
>> 
>> The first patch had some left over stuff from the original flow extension
>> flags I had added.  That bit is removed in this patch.
>> 
>> The second had some left over comments that stated we ignored bits in the
>> masks when we actually match them.
>> 
>> This work is based on input from Ben Hutchings.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
