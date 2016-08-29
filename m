From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] ip-route: Prevent some double spaces in output
Date: Mon, 29 Aug 2016 10:36:15 -0700
Message-ID: <20160829103615.1dd5349e@xeon-e3>
References: <1471945965-17331-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36415 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754476AbcH2RgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 13:36:03 -0400
Received: by mail-pf0-f170.google.com with SMTP id h186so54070870pfg.3
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 10:36:03 -0700 (PDT)
In-Reply-To: <1471945965-17331-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Aug 2016 11:52:45 +0200
Phil Sutter <phil@nwl.cc> wrote:

> The code is a bit messy, as it starts with space after text and at some
> point switches to space before text. But either way, printing space
> before *and* after text almost certainly leads to printing more
> whitespace than necessary.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---

Applied
