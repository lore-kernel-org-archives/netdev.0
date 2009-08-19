From: David Miller <davem@davemloft.net>
Subject: Re: Socket C/R additional features
Date: Tue, 18 Aug 2009 20:36:19 -0700 (PDT)
Message-ID: <20090818.203619.263713537.davem@davemloft.net>
References: <1250625435-16299-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: orenl@librato.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750870AbZHSDgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 23:36:08 -0400
In-Reply-To: <1250625435-16299-1-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>
Date: Tue, 18 Aug 2009 12:57:12 -0700

> This is an updated version of my previous patch set, with the fourth patch
> removed.  This is rebased on current v17-dev and includes Serge's
> recommended changes to may_setgid().

I have no fundamental problems with these changes, you can
attach my ACK to the networking bits if you want:

Acked-by: David S. Miller <davem@davemloft.net>
