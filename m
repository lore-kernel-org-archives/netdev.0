From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Wed, 07 Feb 2007 00:13:10 -0800 (PST)
Message-ID: <20070207.001310.91210854.davem@davemloft.net>
References: <20070206215806.GA5109@elte.hu>
	<45C974FD.5070404@trash.net>
	<20070207080722.GC2434@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, akpm@linux-foundation.org, netdev@vger.kernel.org,
	dipankar@in.ibm.com, paulmck@us.ibm.com
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965680AbXBGINK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 03:13:10 -0500
In-Reply-To: <20070207080722.GC2434@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 7 Feb 2007 09:07:22 +0100

> Dave, Patrick, can we lift the nack on PREEMPT_RCU, as far as networking 
> goes?

After Patrick's fixups, sure.
