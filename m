From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V2 03/10] net/sched: Macro instead of CONFIG_NET_CLS_ACT
 ifdef
Date: Fri, 04 Mar 2016 08:54:38 -0800
Message-ID: <56D9BDCE.8000303@gmail.com>
References: <1457016960-27832-1-git-send-email-amir@vadai.me> <1457016960-27832-4-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Amir Vadai <amir@vadai.me>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35168 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756801AbcCDQyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 11:54:55 -0500
Received: by mail-pf0-f196.google.com with SMTP id x188so1271640pfb.2
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 08:54:55 -0800 (PST)
In-Reply-To: <1457016960-27832-4-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-03 06:55 AM, Amir Vadai wrote:
> Introduce the macros tc_no_actions and tc_for_each_action to make code
> clearer.
> 
> Suggested-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Amir Vadai <amir@vadai.me>
> ---

Acked-by: John Fastabend <john.r.fastabend@intel.com>

This should clean up the driver implementation a bit thanks.
