From: "Vasanthy Kolluri (vkolluri)" <vkolluri@cisco.com>
Subject: RE: [PATCH net-next 1/2] enic: remove dead code
Date: Wed, 29 Sep 2010 22:16:33 -0700
Message-ID: <212AA327A3557741A058E787E0618873042E0D01@xmb-sjc-219.amer.cisco.com>
References: <20100929152930.520cc3b4@s6510><212AA327A3557741A058E787E0618873042E0BC6@xmb-sjc-219.amer.cisco.com><20100930114958.59c438d7@s6510> <20100929.195720.241921649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Scott Feldman (scofeldm)" <scofeldm@cisco.com>,
	"Roopa Prabhu (roprabhu)" <roprabhu@cisco.com>
To: "David Miller" <davem@davemloft.net>, <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:46410 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481Ab0I3FQg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 01:16:36 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100929.195720.241921649.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. I'll remove it.

-Vasanthy

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, September 29, 2010 7:57 PM
To: shemminger@vyatta.com
Cc: Vasanthy Kolluri (vkolluri); netdev@vger.kernel.org; Scott Feldman
(scofeldm); Roopa Prabhu (roprabhu)
Subject: Re: [PATCH net-next 1/2] enic: remove dead code

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 30 Sep 2010 11:49:58 +0900

> Ok, but Linux tree is not the repository for "possible future
enhancements".
> Do it or remove it.

Agreed, remove it now and add it back when you submit the patches that
use the code.

The code is in the repository history so it's not like it's lost.
