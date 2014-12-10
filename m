From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Use nl_proto_a2n for filtering by netlink
 proto
Date: Tue, 9 Dec 2014 20:40:43 -0800
Message-ID: <20141209204043.1ebea273@urahara>
References: <1417827139-10241-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51927 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265AbaLJEkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:40:52 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so1387340pab.19
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 20:40:52 -0800 (PST)
In-Reply-To: <1417827139-10241-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  6 Dec 2014 02:52:19 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Now it is posible to filter by existing Netlink protos:
> 
>     ss -A netlink src uevent
>     ss -A netlink src nft
>     ss -A netlink src genl
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied
