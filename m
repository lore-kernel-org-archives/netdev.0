From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2-net-next] bridge: mdb: add support for
 offloaded mdb entries
Date: Sun, 6 Mar 2016 12:48:16 -0800
Message-ID: <20160306124816.1c5110d5@xeon-e3>
References: <1456151173-12370-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35626 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbcCFUsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 15:48:04 -0500
Received: by mail-pa0-f46.google.com with SMTP id bj10so66228874pad.2
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 12:48:03 -0800 (PST)
In-Reply-To: <1456151173-12370-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Feb 2016 15:26:13 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Elad Raz <eladr@mellanox.com>
> 
> Mark MDB entries which are offloaded to HW with "offload" flag
> 
> Signed-off-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  bridge/mdb.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Applied, took some defuzzing.
