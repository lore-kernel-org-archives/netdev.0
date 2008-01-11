From: David Miller <davem@davemloft.net>
Subject: Re: my NAPI patches
Date: Thu, 10 Jan 2008 20:05:18 -0800 (PST)
Message-ID: <20080110.200518.67237185.davem@davemloft.net>
References: <20080108.150848.116653308.davem@davemloft.net>
	<20080110194421.589d09df@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jacliburn@bellsouth.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37636
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752962AbYAKEFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 23:05:19 -0500
In-Reply-To: <20080110194421.589d09df@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jacliburn@bellsouth.net>
Date: Thu, 10 Jan 2008 19:44:21 -0600

> On Tue, 08 Jan 2008 15:08:48 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > 
> > Can people do me a favor and do more constructive things like test
> > that my patches really do fix the "device down during packet flood"
> > bug 
> 
> Hi Dave,
> 
> Your patches seem to work for the atl1 NAPI implementation.  I can drop
> the interface just fine while hammering the NIC with packets from iperf.

Thanks a lot for testing.
