From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix endianness on tipc subscriber messages
Date: Mon, 08 Mar 2010 15:38:11 -0800 (PST)
Message-ID: <20100308.153811.109635961.davem@davemloft.net>
References: <20100308200315.GE23634@hmsreliant.think-freely.org>
	<29C1DC0826876849BDD9F1C67ABA29430728D116@ala-mail09.corp.ad.wrs.com>
	<20100308.125429.14323494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51765
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755893Ab0CHXhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 18:37:52 -0500
In-Reply-To: <20100308.125429.14323494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Allan, I don't think you're being reasonable at all.

You tell Neil he's breaking things, and that his code isn't following
the current spec.

Neil asks where the spec is.

And you tell him your out-of-tree code is the spec.

That's absolutely rediculious.  It is totally unreasonable to require
Neil to unravel the mess that is the out-of-tree TIPC implementation
in order to figure out what the current protocol "spec" is.

You're doing a lot of "oh crap, don't do this, you'll break this or
that."  But frankly, you really don't care what's in the upstream
kernel.  If you did, your stuff wouldn't be out of tree.

Therefore I take every piece of feedback you give to Neil's
patches with a grain of salt, at best.
