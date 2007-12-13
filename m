From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 4/4] sky2: rtnl_lock out of loop will be faster
Date: Thu, 13 Dec 2007 14:26:46 +0800
Message-ID: <4760D0A6.8020305@cn.fujitsu.com>
References: <475FA0C1.8000701@cn.fujitsu.com> <20071212083011.731773b9@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:53905 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbXLMG3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 01:29:53 -0500
In-Reply-To: <20071212083011.731773b9@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2007-12-13 0:30:
> Umm, okay but it doesn't matter really, there can only be 2 ports and
> 90+% of the boards only have one port.  So why bother??
> 

Thanks Stephen.
David, please ignore all of the four patches.

