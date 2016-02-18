From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/5] iplink: bridge_slave: export read-only
 values
Date: Wed, 17 Feb 2016 17:52:57 -0800
Message-ID: <20160217175257.2dc3af07@xeon-e3>
References: <1455635335-9973-1-git-send-email-razor@blackwall.org>
	<1455635335-9973-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36083 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424276AbcBRBwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 20:52:46 -0500
Received: by mail-pf0-f173.google.com with SMTP id e127so21590878pfe.3
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 17:52:46 -0800 (PST)
In-Reply-To: <1455635335-9973-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Feb 2016 16:08:51 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Export all the read-only values that get returned about a bridge port
> such as the timers, the ids, designated_port and cost,
> topology_change_ack and config_pending. For the bridge ids the
> br_dump_bridge_id function is exported from iplink_bridge.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---

Applied the series.
