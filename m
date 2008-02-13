From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/3] fib_trie: update (redo)
Date: Wed, 13 Feb 2008 11:58:05 -0800
Message-ID: <20080213195805.493794050@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:60846 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755307AbYBMUC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 15:02:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This supersedes yesterday's changes. It doesn't change list.h
because that seems to make people queasy, even if it is a clone
of existing code.  Moves the trie related special files to debugfs.

-- 
Stephen Hemminger <shemminger@vyatta.com>

