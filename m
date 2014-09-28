From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip monitor: Skip IPv6 ND user option messages
Date: Sun, 28 Sep 2014 16:00:53 -0700
Message-ID: <20140928160053.642174e3@urahara>
References: <1409862262-4419-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43572 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbaI1XBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 19:01:07 -0400
Received: by mail-pa0-f48.google.com with SMTP id bj1so9419468pad.7
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 16:01:06 -0700 (PDT)
In-Reply-To: <1409862262-4419-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Sep 2014 23:24:22 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> IPv6 router sends ND messages with RDNSS option
> which causes the printing of unknown message by 'ip monitor':
> 
>     Unknown message: 0000004c 00000044 00000000
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied.
