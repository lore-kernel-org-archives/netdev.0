From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: Re: [PATCH 0/4] netxen: endianness fixes
Date: Thu, 14 Jan 2010 06:57:47 -0800
Message-ID: <821ABD80-7BA0-4A8B-B7DC-87D3B0BA9ADF@qlogic.com>
References: <1263465787-28203-1-git-send-email-amit.salecha@qlogic.com>
 <20100114.030854.52825026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55004 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab0ANO5t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 09:57:49 -0500
In-Reply-To: <20100114.030854.52825026.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 14, 2010, at 3:08 AM, David Miller wrote:

> You mean in all this time, nobody noticed that reading the MAC
> address isn't done correctly on big-endian?
> 
> Well then I guess all of these small endianness fixes aren't
> very critical this late in the RC series.

The MAC fix doesn't change any functionality, just changing data types.
It was working on big-endian machines.

-Dhananjay


