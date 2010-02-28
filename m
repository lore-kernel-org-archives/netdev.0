From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-next-2.6 2010-02-27
Date: Sun, 28 Feb 2010 00:41:18 -0800 (PST)
Message-ID: <20100228.004118.179937353.davem@davemloft.net>
References: <cover.1267276098.git.marcel@holtmann.org>
	<20100228.001918.260094664.davem@davemloft.net>
	<1267345996.8849.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031582Ab0B1IlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 03:41:00 -0500
In-Reply-To: <1267345996.8849.93.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sun, 28 Feb 2010 00:33:16 -0800

> that is embarrassing. I indeed just forgot to call git push after
> updating the tree. Sorry about that. Try again, they should show up now.

Ok thanks.

But I just noticed that patch #9 is bogus, it ends up mixing
code and variable declarations in the function.  Please
fix this and resend your pull request.
