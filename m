From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/7] 8139cp: Fix TSO/scatter-gather descriptor setup
Date: Tue, 22 Sep 2015 23:59:03 +0200
Message-ID: <20150922215903.GA8594@electric-eye.fr.zoreil.com>
References: <1442843991.7367.4.camel@infradead.org>
 <1442844165.7367.14.camel@infradead.org>
 <20150921210139.GB4559@electric-eye.fr.zoreil.com>
 <1442872067.7367.86.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44628 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759198AbbIVWCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 18:02:00 -0400
Content-Disposition: inline
In-Reply-To: <1442872067.7367.86.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> What do you think of finally enabling hw csum and TSO by default, btw?

Your router can actively use it and you'll have to keep the pieces
together if it breaks, right ? So I'd go for it.

-- 
Ueimor
