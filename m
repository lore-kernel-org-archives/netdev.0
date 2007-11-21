From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 9418] New: Funcation tcp_v6_md5_do_del return
 has error.
Date: Tue, 20 Nov 2007 17:29:36 -0800 (PST)
Message-ID: <20071120.172936.265209680.davem@davemloft.net>
References: <bug-9418-10286@http.bugzilla.kernel.org/>
	<20071120124618.9a348f33.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	ming-baini@163.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753524AbXKUB3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 20:29:38 -0500
In-Reply-To: <20071120124618.9a348f33.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Yoshifuji just posted 4 patches which together should fix this
one, I'll add them to my net-2.6 tree.

Thanks.
