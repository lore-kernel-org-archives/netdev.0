From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] xfrm: remove duplicated include
Date: Mon, 27 Jul 2015 14:37:15 -0700
Message-ID: <20150727143715.4bd4acfd@urahara>
References: <1437813864-4368-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33922 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbbG0VhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:37:05 -0400
Received: by pdbbh15 with SMTP id bh15so58288054pdb.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:37:04 -0700 (PDT)
In-Reply-To: <1437813864-4368-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Jul 2015 04:44:24 -0400
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> Remove dupldated include for <linux/xfrm.h>, since it's already
> included by 'xfrm.h'.
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, thanks
