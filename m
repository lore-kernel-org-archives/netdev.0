From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [[PATCH iproute2/net-next v2] 2/4] tc: flower: document SCTP
 ip_proto
Date: Fri, 2 Dec 2016 15:06:08 -0800
Message-ID: <20161202150608.746eb843@xeon-e3>
References: <1480668321-20875-1-git-send-email-simon.horman@netronome.com>
        <1480668321-20875-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35063 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbcLBXGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 18:06:10 -0500
Received: by mail-pf0-f174.google.com with SMTP id i88so54625334pfk.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 15:06:10 -0800 (PST)
In-Reply-To: <1480668321-20875-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Dec 2016 09:45:19 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Add SCTP ip_proto to help text and man page.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

This doesn't apply cleanly to current net-next git.
Probably some of the other man page changes caused reject.
