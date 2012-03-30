From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v3 5/5] r8169: support RTL8411
Date: Fri, 30 Mar 2012 09:25:21 +0200
Message-ID: <20120330072521.GA11548@electric-eye.fr.zoreil.com>
References: <1333089184-1773-5-git-send-email-hayeswang@realtek.com> <1333090086-1815-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56245 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755342Ab2C3H2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2012 03:28:17 -0400
Content-Disposition: inline
In-Reply-To: <1333090086-1815-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
> Support the new chip RTL8411.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

I do not see any change related to rtl_init_jumbo_ops. If NULL is ok for
jumbo_{enable / disable}, it deserves to be outlined in the commit
message.

No reviewer can figure what's going on otherwise.

-- 
Ueimor
