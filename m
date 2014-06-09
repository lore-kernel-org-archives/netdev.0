From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] do not exit silently when link is not found
Date: Mon, 9 Jun 2014 12:38:57 -0700
Message-ID: <20140609123857.2fba65bf@nehalam.linuxnetplumber.net>
References: <1401836805-26937-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:60256 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020AbaFITsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:48:02 -0400
Received: by mail-pb0-f44.google.com with SMTP id rq2so5303526pbb.31
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 12:48:01 -0700 (PDT)
In-Reply-To: <1401836805-26937-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  3 Jun 2014 16:06:45 -0700
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> When we create a tunnel on top of a link and the link specified
> in cmdline doesn't exist, an error message should be shown.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 

Applied
