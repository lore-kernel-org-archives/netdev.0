From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][SCTP]: Use snmp_fold_field instead of a homebrew
 analogue.
Date: Sat, 09 Feb 2008 23:24:01 -0800 (PST)
Message-ID: <20080209.232401.06134281.davem@davemloft.net>
References: <47AC3757.6020405@openvz.org>
	<47AC6E6A.4000101@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, lksctp-developers@lists.sourceforge.net,
	netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33572
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759195AbYBJHX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:23:29 -0500
In-Reply-To: <47AC6E6A.4000101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 08 Feb 2008 09:59:54 -0500

> Pavel Emelyanov wrote:
> > SCPT already depends in INET, so this doesn't create additional
> > dependencies.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
