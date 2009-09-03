From: David Miller <davem@davemloft.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Thu, 03 Sep 2009 16:31:01 -0700 (PDT)
Message-ID: <20090903.163101.154177782.davem@davemloft.net>
References: <4A9FD2DC.7070807@trash.net>
	<Pine.LNX.4.64.0909031911400.3490@ask.diku.dk>
	<4AA00351.4090601@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hawk@diku.dk, cl@linux-foundation.org, eric.dumazet@gmail.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38450
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755300AbZICXaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 19:30:46 -0400
In-Reply-To: <4AA00351.4090601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 03 Sep 2009 19:56:33 +0200

> It would probably also be possible to use TC classifiers for queue
> selection.

You mean just like Intel's multiqueue scheduler and multiqueue
classifiers which we already have in the tree :-)
