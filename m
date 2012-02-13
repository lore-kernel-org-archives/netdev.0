From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] netdev: driver: ethernet: add cpsw address lookup
 engine support
Date: Mon, 13 Feb 2012 09:31:15 -0800
Message-ID: <20120213093115.481e556e@nehalam.linuxnetplumber.net>
References: <1329113061-13026-1-git-send-email-mugunthanvnm@ti.com>
	<1329113061-13026-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51640 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503Ab2BMRbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 12:31:18 -0500
In-Reply-To: <1329113061-13026-2-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Feb 2012 11:34:20 +0530
Mugunthan V N <mugunthanvnm@ti.com> wrote:

> static struct ale_control_info ale_controls[] = {

Can you make this table const?
