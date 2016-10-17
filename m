From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: add support for the multicast flood
 flag
Date: Mon, 17 Oct 2016 05:30:05 -0700
Message-ID: <20161017053005.34fade2c@xeon-e3>
References: <1476374060-23363-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35673 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932911AbcJQM3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 08:29:51 -0400
Received: by mail-pf0-f170.google.com with SMTP id s8so79127968pfj.2
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 05:29:50 -0700 (PDT)
In-Reply-To: <1476374060-23363-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Oct 2016 17:54:20 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> Recently a new per-port flag was added which controls the flooding of
> unknown multicast, this patch adds support for controlling it via iproute2.
> It also updates the man pages with information about the new flag.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---

Applied, thanks.
