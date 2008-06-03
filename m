From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/05] smc911x: Remove unused 8-bit I/O operations
Date: Tue, 3 Jun 2008 15:48:34 -0700
Message-ID: <20080603154834.428d89cc.akpm@linux-foundation.org>
References: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>
	<20080602113714.28716.10248.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, magnus.damm@gmail.com, lethal@linux-sh.org,
	jeff@garzik.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49075 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750971AbYFCWsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 18:48:40 -0400
In-Reply-To: <20080602113714.28716.10248.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 Jun 2008 20:37:14 +0900
Magnus Damm <magnus.damm@gmail.com> wrote:

> From: Magnus Damm <magnus.damm@gmail.com>
> ...
> Signed-off-by: Magnus Damm <damm@igel.co.jp>

It's a bit strange to have the Author: line using one email address and
the s-o-b using a different one. (It's fairly common though).

It is fixable by putting the desired From: address right at the top of
the changelog, in the email body.

