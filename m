From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] [iputils] Fix asymm messages.
Date: Mon, 09 Apr 2007 13:16:51 +0900 (JST)
Message-ID: <20070409.131651.18241005.yoshfuji@linux-ipv6.org>
References: <1175624435275-git-send-email-jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40970 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbXDIEPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 00:15:52 -0400
In-Reply-To: <1175624435275-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1175624435275-git-send-email-jheffner@psc.edu> (at Tue,  3 Apr 2007 14:20:34 -0400), John Heffner <jheffner@psc.edu> says:

> We should only print the asymm messages in tracepath/6 when you receive a
> TTL expired message, because this is the only time when we'd expect the
> same number of hops back as our TTL was set to for a symmetric path.

applied. thanks.

--yoshfuji
