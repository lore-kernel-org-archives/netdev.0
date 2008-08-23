From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [bisected] Weird sysctl regression
Date: Sat, 23 Aug 2008 19:16:51 +0100
Message-ID: <20080823181651.GM28946@ZenIV.linux.org.uk>
References: <87fxoyal9j.fsf@natisbad.org> <20080823084936.GK28946@ZenIV.linux.org.uk> <87wsi7en1m.fsf@natisbad.org> <20080823170248.GL28946@ZenIV.linux.org.uk> <87ljynd582.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45823 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbYHWSQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 14:16:52 -0400
Content-Disposition: inline
In-Reply-To: <87ljynd582.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 07:13:49PM +0200, Arnaud Ebalard wrote:

> I already tested 26.27-rc4 and even net-next-2.6 (recently released one
> based on rc4 with some bug fixes). Problem is still here.

Just to make sure: that's rc4 without any additional patches?
