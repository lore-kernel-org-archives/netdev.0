From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Mon, 27 Apr 2009 02:45:17 -0700 (PDT)
Message-ID: <20090427.024517.25936454.davem@davemloft.net>
References: <20090423182839.GD30405@hmsreliant.think-freely.org>
	<49F1C847.2020106@cosmosbay.com>
	<20090424183743.GA17303@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51901
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751763AbZD0JpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:45:24 -0400
In-Reply-To: <20090424183743.GA17303@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 24 Apr 2009 14:37:43 -0400

> The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcastOctets and
> OutMcastOctets:
> http://tools.ietf.org/html/rfc4293
> But it seems we don't track those in any way that easy to separate from other
> protocols.  This patch adds those missing counters to the stats file. Tested
> successfully by me
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next-2.6, thanks Neil.
