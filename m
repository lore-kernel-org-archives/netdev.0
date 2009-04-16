From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 15:16:41 -0700 (PDT)
Message-ID: <20090416.151641.220683663.davem@davemloft.net>
References: <alpine.DEB.1.10.0904161136220.15629@qirst.com>
	<20090416174422.GB28978@hmsreliant.think-freely.org>
	<alpine.DEB.1.10.0904161508520.15835@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, dlstevens@us.ibm.com
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754410AbZDPWQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 18:16:49 -0400
In-Reply-To: <alpine.DEB.1.10.0904161508520.15835@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Thu, 16 Apr 2009 15:12:43 -0400 (EDT)

> On Thu, 16 Apr 2009, Neil Horman wrote:
> 
>> I'm sorry, I misread it (confused the definiton of a bitfield with its default
>> value.  As Dave noted, the default needs to be the current behavior, not your
>> new behavior.  Until thats changed, I rescind my Ack
> 
> Well guess then we need the global proc setting after all.

No Christoph, do this right.

Linux by default will behave the way it has for 15+ years.  And if an
application wants new behavior, you have to ask for it.

End of story.
