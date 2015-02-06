From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] enic: enic_main: fix sparse warnings
Date: Thu, 05 Feb 2015 16:05:45 -0800 (PST)
Message-ID: <20150205.160545.1060261002310869025.davem@davemloft.net>
References: <1423150453-26417-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, ssujith@cisco.com, _govind@gmx.com,
	neepatel@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prabhakar.csengg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbbBFAFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:05:46 -0500
In-Reply-To: <1423150453-26417-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Thu,  5 Feb 2015 15:34:13 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warnings:
> 
> enic_main.c:92:28: warning: symbol 'mod_table' was not declared. Should it be static?
> enic_main.c:109:28: warning: symbol 'mod_range' was not declared. Should it be static?
> enic_main.c:1306:5: warning: symbol 'enic_busy_poll' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
