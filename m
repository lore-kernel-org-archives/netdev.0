From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_emac:Fix translation logic for buffer
 descriptor
Date: Tue, 22 Mar 2011 03:22:31 -0700 (PDT)
Message-ID: <20110322.032231.193716852.davem@davemloft.net>
References: <1300788382-12658-1-git-send-email-srk@ti.com>
	<4D8875C1.9090004@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: srk@ti.com, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: sshtylyov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48121
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753241Ab1CVKVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 06:21:53 -0400
In-Reply-To: <4D8875C1.9090004@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@mvista.com>
Date: Tue, 22 Mar 2011 13:11:13 +0300

> Hello.
> 
> On 22-03-2011 13:06, Sriramakrishnan wrote:
> 
>> With recent changes to the driver(switch to new cpdma layer),
>> the support for buffer descriptor address translation logic
>> is broken. This affects platforms where the physical address of
>> the descriptors as seen by the DMA engine is different from the
>> physical address.
> 
>> Original Patch adding translation logic support:
>> Commit: ad021ae8862209864dc8ebd3b7d3a55ce84b9ea2
> 
>> Signed-off-by: Sriramakrishnan <srk@ti.com>
> 
>    AFAIK, full name is required for signoff.

Indeed, please provide your full name in your signoff lines.

Thanks.
