From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] tcp: use RTAX_CWND for outgoing connections properly
Date: Thu, 23 Dec 2010 00:26:21 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012230023490.16569@pobox.suse.cz>
References: <alpine.LNX.2.00.1012172310400.16569@pobox.suse.cz> <alpine.LNX.2.00.1012221059340.16569@pobox.suse.cz> <20101222.115721.39176015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56817 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697Ab0LVX0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Dec 2010 18:26:23 -0500
In-Reply-To: <20101222.115721.39176015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Dec 2010, David Miller wrote:

> > Besides that, any comments on this, please?
> 
> It's in my backlog, patience is a virtue.

Please just disregard it, it's not needed with newer kernels. Thanks,

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
