From: David Miller <davem@davemloft.net>
Subject: net-2.6 state...
Date: Mon, 02 May 2011 15:20:44 -0700 (PDT)
Message-ID: <20110502.152044.59668681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39502
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751646Ab1EBWVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 18:21:17 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id F1E1924C088
	for <netdev@vger.kernel.org>; Mon,  2 May 2011 15:20:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Right now I'm sorting through patchwork to make sure anything that
belongs in net-2.6, is there.

Then I'm going to push things out to Linus.

We will be in a more serious lock down mode after that.  So I really
only want to see obvious critical fixes going into net-2.6.  Even
comment typos will be put into net-next-2.6.

Please cooperate with this policy and everything will go smoothly.

There is nothing I like more than seeing people work on bug fixes at
this point in the -rc* series, so if you want to make me (as well as
the users reporting these things) really happy, fix some bugs. :-)

Thanks!
