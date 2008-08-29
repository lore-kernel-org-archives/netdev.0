From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 7/7] [RFC] qlge: New Driver: Add debug source file
 qlge_dbg.c
Date: Fri, 29 Aug 2008 14:23:44 -0700
Message-ID: <20080829142344.58d0b9f7@extreme>
References: <20080829210610.GA14654@susedev.qlogic.org>
	<12200441023508-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:46400 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756537AbYH2VXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 17:23:46 -0400
In-Reply-To: <12200441023508-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Aug 2008 14:08:22 -0700
Ron Mercer <ron.mercer@qlogic.com> wrote:

> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qlge/qlge_dbg.c |  858 +++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 858 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/qlge/qlge_dbg.c
> 

This looks like a natural thing to put in a debugfs interface.
See sky2, skge for how.
