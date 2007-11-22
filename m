From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [README] away until Dec 3rd
Date: Thu, 22 Nov 2007 21:57:14 +0900
Message-ID: <200711222157.JIE05256.SQOFHFVtFJLOMO@I-love.SAKURA.ne.jp>
References: <20071120.202921.78239222.davem@davemloft.net>
	<20071122042747.GA5041@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:51710 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407AbXKVM5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 07:57:19 -0500
In-Reply-To: <20071122042747.GA5041@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I have a question.

Yesterday, I posted a patch based on 2.6.24-rc3-mm1 that modifies
the following files.

 include/linux/security.h |   34 +++++++++++++++++++++++++++++-----
 net/core/datagram.c      |   26 ++++++++++++++++++++++++--
 net/socket.c             |    7 +++++--
 security/dummy.c         |   13 ++++++++++---
 security/security.c      |   10 ++++++++--

But you say that I should make patches based on the net-2.6.25 tree.
Which tree ("-mm" or "net-2.6.25") should I use for making this patch?

There is no pending objection at LSM-ml so far, and
I'm asking for an approval from one of the core developers at netdev-ml.

Regards.

