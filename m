From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] dccp: Initialise option area of v4/v6 request
 socket
Date: Tue, 10 Jun 2008 12:40:30 -0700 (PDT)
Message-ID: <20080610.124030.151295293.davem@davemloft.net>
References: <1213102423-27486-7-git-send-email-gerrit@erg.abdn.ac.uk>
	<1213102423-27486-8-git-send-email-gerrit@erg.abdn.ac.uk>
	<20080610143812.GB26686@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
	netdev@vger.kernel.org, yjwei@cn.fujitsu.com
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59932
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754008AbYFJTkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:40:31 -0400
In-Reply-To: <20080610143812.GB26686@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 10 Jun 2008 11:38:12 -0300

> Please consider the following patch instead, it is compile tested only
> but should be OK.

I've applied this, thanks Arnaldo.

Gerrit, please be mindful of this when rebuilding your
DCCP bug fix tree.  Thanks!
