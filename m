From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 41/43] drivers/net/wireless/b43: fix warning: format
 not a string literal and no ...
Date: Tue, 17 Feb 2009 19:49:33 -0800 (PST)
Message-ID: <20090217.194933.98457883.davem@davemloft.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
	<20090214214956.24377.19315.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752833AbZBRDtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 22:49:49 -0500
In-Reply-To: <20090214214956.24377.19315.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Sat, 14 Feb 2009 22:50:06 +0100

> Fix this compilation warning:
>   drivers/net/wireless/b43/main.c: In function 'b43_print_fw_helptext':
>   drivers/net/wireless/b43/main.c:1971: warning: format not a string literal and no format arguments
>   drivers/net/wireless/b43/main.c:1973: warning: format not a string literal and no format arguments
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
