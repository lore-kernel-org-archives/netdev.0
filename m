From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe
Date: Thu, 20 Nov 2014 07:14:44 +0100
Message-ID: <20141120061444.GD26860@1wt.eu>
References: <1416463480-29036-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, khandelwal.deepak.1987@gmail.com,
	vyasevich@gmail.com, tuexen@fh-muenster.de, dborkman@redhat.com,
	Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Zhu Yanjun <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:56424 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781AbaKTGPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 01:15:07 -0500
Content-Disposition: inline
In-Reply-To: <1416463480-29036-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Nov 20, 2014 at 02:04:40PM +0800, Zhu Yanjun wrote:
> 2.6.x kernels require a similar logic change as commit 2c0d6ac894a
> [sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe] 
> introduces for newer kernels.

(...)
Queued for 2.6.32.64, thanks!

Willy
