From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 auto speed down issue
Date: Fri, 29 Mar 2013 00:19:55 +0100
Message-ID: <20130328231955.GA26182@electric-eye.fr.zoreil.com>
References: <4EECA12DD88643FD9006350514D96C8E@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bowgotsai@google.com, "'Ryankao'" <ryankao@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59279 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965Ab3C1XUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 19:20:06 -0400
Content-Disposition: inline
In-Reply-To: <4EECA12DD88643FD9006350514D96C8E@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> Do you have any suggestion about this?

Your description suggests that testing against the link partner ability
to work at 10M instead of testing for tp->link_ok could be good enough.

Does it make sense ?

-- 
Ueimor
