From: David Miller <davem@davemloft.net>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 17:00:38 -0700 (PDT)
Message-ID: <20100420.170038.130590455.davem@davemloft.net>
References: <Pine.LNX.4.64.1004201834190.29017@hs20-bc2-1.build.redhat.com>
	<20100420.164505.34362726.davem@davemloft.net>
	<Pine.LNX.4.64.1004201947470.29017@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751597Ab0DUAAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 20:00:33 -0400
In-Reply-To: <Pine.LNX.4.64.1004201947470.29017@hs20-bc2-1.build.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 20 Apr 2010 19:57:45 -0400 (EDT)

>> We're not reverting the commit you mention, we're going to fix
>> whatever bug exists instead.
> 
> So have a fun searching for them :-/

When you report a problem and your knee-jerk reaction is "revert this
commit", expect some push back.

We'll instead analyze this bug and take the time to figure out the
most appropriate course of action.
