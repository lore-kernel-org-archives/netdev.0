From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/: all net/ cleanup with ARRAY_SIZE
Date: Sun, 16 Sep 2007 16:42:03 -0700 (PDT)
Message-ID: <20070916.164203.38709930.davem@davemloft.net>
References: <Pine.LNX.4.64.0709020235420.22012@localhost.localdomain>
	<11887290181154-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rpjday@mindspring.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cr_quan@163.com
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38151
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754002AbXIPXmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:42:03 -0400
In-Reply-To: <11887290181154-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Cheng <crquan@gmail.com>
Date: Sun,  2 Sep 2007 18:30:17 +0800

> Signed-off-by: Denis Cheng <crquan@gmail.com>

You already submitted the net/ipv4/af_inet.c case
seperately, so I had to remove it from this patch for
it to apply properly.

Please keep your patches straight to avoid problems
like this.

Thans.
