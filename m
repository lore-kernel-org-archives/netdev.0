From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 14:02:51 -0700 (PDT)
Message-ID: <20070510.140251.02302242.davem@davemloft.net>
References: <464370BA.3020907@hp.com>
	<20070510.133216.95506791.davem@davemloft.net>
	<46438568.1020403@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, ian.mcdonald@jandi.co.nz,
	krkumar2@in.ibm.com, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53533
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760815AbXEJVCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:02:49 -0400
In-Reply-To: <46438568.1020403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 10 May 2007 13:49:44 -0700

> I'd think one would only do this in those situations/places where a
> natural "out of driver" queue develops in the first place wouldn't
> one?

Indeed.
