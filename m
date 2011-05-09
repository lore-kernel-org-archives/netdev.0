From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: fix wrongly reported speed and port
Date: Mon, 09 May 2011 11:49:32 -0700 (PDT)
Message-ID: <20110509.114932.112589716.davem@davemloft.net>
References: <1304550311.28342.19.camel@dream>
	<4DC44487.4070207@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klebers@linux.vnet.ibm.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44777
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1EISuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:50:04 -0400
In-Reply-To: <4DC44487.4070207@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Fri, 06 May 2011 15:57:11 -0300

> On 05/04/2011 08:05 PM, Kleber Sacilotto de Souza wrote:
>>  Currently EHEA reports to ethtool as supporting 10M, 100M, 1G and
>>  10G and connected to FIBRE independent of the hardware configuration.
>>  However, when connected to FIBRE the only supported speed is 10G
>>  full-duplex, and the other speeds and modes are only supported
>>  when connected to twisted pair.
>>
>>  Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
> Acked-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks.
