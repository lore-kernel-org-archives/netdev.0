From: David Miller <davem@davemloft.net>
Subject: Re: syncing net GIT trees with upstream...
Date: Mon, 08 Sep 2008 17:02:13 -0700 (PDT)
Message-ID: <20080908.170213.195859407.davem@davemloft.net>
References: <20080908.165307.164971165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57482
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752538AbYIIACU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:02:20 -0400
In-Reply-To: <20080908.165307.164971165.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 08 Sep 2008 16:53:07 -0700 (PDT)

> 2) I'm in the process of doing the same for net-next-2.6

This now done too.

John, take a quick look and make sure I did the merge conflict
of net/mac80211/mlme.c correctly.  It arose because of the
revert done in Linus's tree while I was away.

Thanks.
