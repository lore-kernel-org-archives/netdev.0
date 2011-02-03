From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 0/3] r8169 driver fixes
Date: Fri, 4 Feb 2011 00:55:00 +0100
Message-ID: <20110203235500.GA9137@electric-eye.fr.zoreil.com>
References: <20110203172557.GA9024@electric-eye.fr.zoreil.com> <20110203.151802.39181951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ivecera@redhat.com, hayeswang@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38377 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab1BCX5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 18:57:32 -0500
Content-Disposition: inline
In-Reply-To: <20110203.151802.39181951.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> These are bug fixes, but this GIT branch is based upon net-next-2.6,
> what is the intent here?

It should have been based on $(git merge-base master net-2.6) instead
of net-ext-2.6.

I'll rebase it after some sleep.

-- 
Ueimor
