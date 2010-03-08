From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked
 mode (v2)
Date: Mon, 08 Mar 2010 13:26:18 -0800 (PST)
Message-ID: <20100308.132618.127647340.davem@davemloft.net>
References: <20100302183312.GB22294@hmsreliant.think-freely.org>
	<20100308.121942.67584963.davem@davemloft.net>
	<20100308211308.GI23634@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, tipc-discussion@lists.sourceforge.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48559
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755431Ab0CHV0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 16:26:01 -0500
In-Reply-To: <20100308211308.GI23634@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 8 Mar 2010 16:13:08 -0500

> On Mon, Mar 08, 2010 at 12:19:42PM -0800, David Miller wrote:
>> 
>> Doesn't apply to net-2.6, Neil please respin.
>> 
> Yes, sorry David, didn't mean to reply so quickly before.  I just looked at your
> net-2.6 tree, and d0021b252eaf65ca07ed14f0d66425dd9ccab9a6 is in there just
> fine.  Not sure if I'm missing something or not, but as far as I can see you've
> already apply the patch properly.

Perfect.
