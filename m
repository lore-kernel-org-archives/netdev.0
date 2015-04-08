From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v2] bonding: Code re-factoring for admin, oper-key
 operations
Date: Wed, 08 Apr 2015 12:12:29 -0400 (EDT)
Message-ID: <20150408.121229.21904699033169430.davem@davemloft.net>
References: <1428448571-1996-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301AbbDHQMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:12:32 -0400
In-Reply-To: <1428448571-1996-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Tue,  7 Apr 2015 16:16:11 -0700

> This patch breaks the rich assignments into it's own statements
> and removes some duplicate code where admin-key, & oper-key are
> updated.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.
