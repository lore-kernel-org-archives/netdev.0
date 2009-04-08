From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2 - Don't use reserved names
Date: Wed, 08 Apr 2009 15:50:14 -0700 (PDT)
Message-ID: <20090408.155014.134842206.davem@davemloft.net>
References: <20090408211656.GA21010@wavehammer.waldi.eu.org>
	<20090408214705.GA12006@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: waldi@debian.org, davem@davemloft.org, netdev@vger.kernel.org
To: tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752371AbZDHWuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 18:50:24 -0400
In-Reply-To: <20090408214705.GA12006@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Michlmayr <tbm@cyrius.com>
Date: Wed, 8 Apr 2009 14:47:05 -0700

> * Bastian Blank <waldi@debian.org> [2009-04-08 23:16]:
>> The mips identifier is reserved by gcc on mips plattforms. Don't use it
>> in the code.
>> 
>> Signed-off-by: Bastian Blank <waldi@debian.org>
> 
> This fixes the compile problem for me on MIPS.
> 
> Tested-by: Martin Michlmayr <tbm@cyrius.com>

Applied, thanks!
