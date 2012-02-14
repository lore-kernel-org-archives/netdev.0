From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: remove the 'poll' module option
Date: Tue, 14 Feb 2012 14:40:08 -0500 (EST)
Message-ID: <20120214.144008.1160894285989893230.davem@davemloft.net>
References: <1329246346-9993-1-git-send-email-mschmidt@redhat.com>
	<1329246842.30697.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, gideonn@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab2BNTkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:40:13 -0500
In-Reply-To: <1329246842.30697.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Tue, 14 Feb 2012 21:14:02 +0200

> On Tue, 2012-02-14 at 20:05 +0100, Michal Schmidt wrote:
>> 'poll' was a debugging option, but turning it on these days leads to
>> kernel panic. Remove it.
>> 
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> Michal - thanks for taking care of it. Your help is truly appreciated.
> 
> Acked-by Eilon Greenstein <eilong@broadcom.com>

Applied.
