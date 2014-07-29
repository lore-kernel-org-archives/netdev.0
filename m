From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv4: clean up cast warning in do_ip_getsockopt
Date: Tue, 29 Jul 2014 16:31:39 -0700 (PDT)
Message-ID: <20140729.163139.845246499907143156.davem@davemloft.net>
References: <1406456947-3226-1-git-send-email-karoly.kemeny@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: karoly.kemeny@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbaG2Xbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 19:31:40 -0400
In-Reply-To: <1406456947-3226-1-git-send-email-karoly.kemeny@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karoly Kemeny <karoly.kemeny@gmail.com>
Date: Sun, 27 Jul 2014 12:29:07 +0200

> Sparse warns because of implicit pointer cast.
> 
> v2: subject line correction, space between "void" and "*"
> 
> Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>

Applied, thank you.
