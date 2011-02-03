From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] r8169 driver fixes
Date: Thu, 03 Feb 2011 15:18:02 -0800 (PST)
Message-ID: <20110203.151802.39181951.davem@davemloft.net>
References: <20110203172557.GA9024@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivecera@redhat.com, hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39110
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752227Ab1BCXR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 18:17:27 -0500
In-Reply-To: <20110203172557.GA9024@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 3 Feb 2011 18:26:11 +0100

> The following series includes Ivan Rx fifo overflow fix and similar
> changes I did after testing with various 8168 chipsets.
> 
> The series is available as
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-davem

These are bug fixes, but this GIT branch is based upon net-next-2.6,
what is the intent here?
