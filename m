From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-next-2.6 2010-02-27
Date: Sun, 28 Feb 2010 00:58:48 -0800 (PST)
Message-ID: <20100228.005848.232750812.davem@davemloft.net>
References: <1267345996.8849.93.camel@localhost.localdomain>
	<20100228.004118.179937353.davem@davemloft.net>
	<1267347161.8849.95.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42613
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031594Ab0B1I63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 03:58:29 -0500
In-Reply-To: <1267347161.8849.95.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sun, 28 Feb 2010 00:52:41 -0800

> Hi Dave,
> 
>> But I just noticed that patch #9 is bogus, it ends up mixing
>> code and variable declarations in the function.  Please
>> fix this and resend your pull request.
> 
> makes it more ugly, but you are right. I updated the tree with a proper
> fix for that one now. Please pull again.

Looks a lot better, pulled thanks!
