From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: replace white-spaces with tabs
Date: Mon, 27 Jul 2015 14:11:09 -0700
Message-ID: <20150727141109.40cfda95@urahara>
References: <1437828893-5347-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34472 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbbG0VK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:10:59 -0400
Received: by pdbbh15 with SMTP id bh15so57993398pdb.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:10:58 -0700 (PDT)
In-Reply-To: <1437828893-5347-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Jul 2015 08:54:53 -0400
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> Replace white-spaces with tabs
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  ip/ip.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 

There were more places that needed this, went ahead and made ip.c and bridge.c
checkpatch clean.
