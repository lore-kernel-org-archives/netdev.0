From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: flower: Fix usage message
Date: Sat, 12 Nov 2016 10:28:59 +0300
Message-ID: <20161112102859.2681325a@samsung9>
References: <1478099398-21639-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36340 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbcKLH3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 02:29:05 -0500
Received: by mail-lf0-f47.google.com with SMTP id t196so26779066lff.3
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 23:29:05 -0800 (PST)
In-Reply-To: <1478099398-21639-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Nov 2016 17:09:58 +0200
Paul Blakey <paulb@mellanox.com> wrote:

> Remove left over usage from removal of eth_type argument.
> 
> Fixes: 488b41d020fb ('tc: flower no need to specify the ethertype')
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> ---

Applied, thanks.
Then I changed usage message to pass checkpatch long line nags.
