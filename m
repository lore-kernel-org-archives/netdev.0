From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 001/001] ipv4: enable use of 240/4 address space
Date: Fri, 11 Jan 2008 12:17:02 +0100
Message-ID: <p73bq7smx1t.fsf@bingen.suse.de>
References: <20080108011057.GA21168@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vince Fuller <vaf@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38389 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756588AbYAKLRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 06:17:04 -0500
In-Reply-To: <20080108011057.GA21168@cisco.com> (Vince Fuller's message of "Mon\, 7 Jan 2008 17\:10\:57 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vince Fuller <vaf@cisco.com> writes:

> from Vince Fuller <vaf@vaf.net>
>
> This set of diffs modify the 2.6.20 kernel to enable use of the 240/4
> (aka "class-E") address space as consistent with the Internet Draft
> draft-fuller-240space-00.txt.

Wouldn't it be wise to at least wait for it becoming an RFC first? 

-Andi
