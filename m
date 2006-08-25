From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp_bic: use BUILD_BUG_ON
Date: Fri, 25 Aug 2006 16:27:20 -0700
Message-ID: <20060825162720.3d4257d7@localhost.localdomain>
References: <20060825010802.GK5204@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58066 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422921AbWHYX1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 19:27:24 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060825010802.GK5204@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please fix the other variants as well htcp, cubic, veno, vegas, ...
Just one patch is necessary with all the files.

-- 
Stephen Hemminger <shemminger@osdl.org>

All non-trivial abstractions, to some degree, are leaky.
