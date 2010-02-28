From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Pull request: bluetooth-next-2.6 2010-02-27
Date: Sun, 28 Feb 2010 00:52:41 -0800
Message-ID: <1267347161.8849.95.camel@localhost.localdomain>
References: <cover.1267276098.git.marcel@holtmann.org>
	 <20100228.001918.260094664.davem@davemloft.net>
	 <1267345996.8849.93.camel@localhost.localdomain>
	 <20100228.004118.179937353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:56637 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031588Ab0B1IyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 03:54:16 -0500
In-Reply-To: <20100228.004118.179937353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > that is embarrassing. I indeed just forgot to call git push after
> > updating the tree. Sorry about that. Try again, they should show up now.
> 
> Ok thanks.
> 
> But I just noticed that patch #9 is bogus, it ends up mixing
> code and variable declarations in the function.  Please
> fix this and resend your pull request.

makes it more ugly, but you are right. I updated the tree with a proper
fix for that one now. Please pull again.

Regards

Marcel


