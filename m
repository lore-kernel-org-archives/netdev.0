From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tipc: add peer remove functionality
Date: Mon, 29 Aug 2016 10:34:40 -0700
Message-ID: <20160829103440.0eaae72a@xeon-e3>
References: <1471853909-29731-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33507 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751691AbcH2Re3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 13:34:29 -0400
Received: by mail-pa0-f51.google.com with SMTP id cy9so30789465pac.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 10:34:29 -0700 (PDT)
In-Reply-To: <1471853909-29731-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Aug 2016 10:18:29 +0200
Richard Alpe <richard.alpe@ericsson.com> wrote:

> This enables a user to remove an offline peer from the kernel data
> structures. This could for example be useful when deliberately scaling
> in peer nodes in a cloud environment.
> 
> This functionality was first merged in:
> f9dec657e4 (Richard Alpe tipc: add peer remove functionality)
> 
> And later backed out (as the kernel counterpart was held up) in:
> 385caeb13b (Stephen Hemminger Revert "tipc: add peer remove functionality")
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied to net-next branch
