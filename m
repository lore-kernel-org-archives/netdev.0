From: David Miller <davem@davemloft.net>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 15:59:25 -0700 (PDT)
Message-ID: <20090416.155925.101004683.davem@davemloft.net>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
	<49E78A79.6050604@cosmosbay.com>
	<alpine.DEB.1.10.0904161553160.23632@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753343AbZDPW7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 18:59:34 -0400
In-Reply-To: <alpine.DEB.1.10.0904161553160.23632@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Thu, 16 Apr 2009 15:55:02 -0400 (EDT)

> But what does it matter? Just changing the kernel should not cause
> increases in latency.

There's firmware running on those cards doing all kinds of
fun things, the firmware gets changed in driver updates,
therefore...
