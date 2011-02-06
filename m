From: "Vasanthy Kolluri (vkolluri)" <vkolluri@cisco.com>
Subject: RE: [net-next-2.6 4/5] enic: Clean up: Remove support for an older version of hardware
Date: Sat, 5 Feb 2011 19:13:26 -0800
Message-ID: <212AA327A3557741A058E787E06188730549144D@xmb-sjc-219.amer.cisco.com>
References: <20110205.175702.226777511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:63002 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab1BFDNb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Feb 2011 22:13:31 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20110205.175702.226777511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This hardware was never shipped to customers. So we are safe removing
it.

Thanks
Vasanthy

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Saturday, February 05, 2011 5:57 PM
To: Vasanthy Kolluri (vkolluri)
Cc: netdev@vger.kernel.org
Subject: Re: [net-next-2.6 4/5] enic: Clean up: Remove support for an
older version of hardware


If this hardware ever shipped to any customers, you cannot
simply remove support for it.

Such code must be retained.
