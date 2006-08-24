From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] IP1000A: IC Plus update 2006-08-22
Date: Fri, 25 Aug 2006 00:07:58 +0200
Message-ID: <20060824220758.GA19637@electric-eye.fr.zoreil.com>
References: <1156268234.3622.1.camel@localhost.localdomain> <20060822232730.GA30977@electric-eye.fr.zoreil.com> <20060823113822.GA17103@electric-eye.fr.zoreil.com> <20060823223032.GA25111@electric-eye.fr.zoreil.com> <026c01c6c71d$0fde1730$4964a8c0@icplus.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penberg@cs.Helsinki.FI, akpm@osdl.org, dvrabel@cantab.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38868 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1422755AbWHXWLu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 18:11:50 -0400
To: Jesse Huang <jesse@icplus.com.tw>
Content-Disposition: inline
In-Reply-To: <026c01c6c71d$0fde1730$4964a8c0@icplus.com.tw>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Huang <jesse@icplus.com.tw> :
[...]

Added:
0039-ip1000-cosmetic-in-ipg_interrupt_handler.txt
0040-ip1000-irq-handler-and-device-close-race.txt
0041-ip1000-schedule-the-host-error-recovery-to-user-context.txt
0042-ip1000-no-need-to-mask-a-constant-field-with-RSVD_MASK.txt

ipg_reset() may still delay for several ms in irq context :o(

-- 
Ueimor
