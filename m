From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [SCTP] Correctly copy addresses in sctp_copy_laddrs
Date: Wed, 09 May 2007 13:51:54 -0700 (PDT)
Message-ID: <20070509.135154.56976607.davem@davemloft.net>
References: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
	<11787398301224-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40500
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754048AbXEIUvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 16:51:53 -0400
In-Reply-To: <11787398301224-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  9 May 2007 15:43:49 -0400

> I broke the  non-wildcard case recently.  This is to fixes it.
> Now, explictitly bound addresses can ge retrieved using the API.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
