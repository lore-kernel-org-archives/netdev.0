From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [r8169 3.10rc5] NETDEV WATCHDOG: eth1 (r8169): transmit queue 0
 timed out
Date: Sun, 16 Jun 2013 10:15:33 +0200
Message-ID: <20130616081533.GA24737@electric-eye.fr.zoreil.com>
References: <20130615184646.GA19439@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53398 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998Ab3FPIPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 04:15:50 -0400
Content-Disposition: inline
In-Reply-To: <20130615184646.GA19439@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> :
> I see this from time to time, but this is the first time in a few months since
> I last saw it..

I guess the driver did not recover, right ?

Which chipset ('dmesg | grep XID') is it ?

-- 
Ueimor
