From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.20 Oopses in xfrm_audit_log
Date: Mon, 12 Feb 2007 15:01:51 -0800
Message-ID: <20070212150151.a454f7c4.akpm@linux-foundation.org>
References: <20070212142138.32983793.akpm@linux-foundation.org>
	<20070212.144938.36664406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ce@ruault.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46301 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030219AbXBLXCS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 18:02:18 -0500
In-Reply-To: <20070212.144938.36664406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon, 12 Feb 2007 14:49:38 -0800 (PST) David Miller <davem@davemloft.net> wrote:
> Andrew, we're already discussing a fix for this in another
> thread today:

Yeah, I noticed.  Vitimised again by those darn MUA vendors and/or
users who bust their In-Reply-To/References headers :(
