From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/3] ip vrf: minor error message cleanups
Date: Mon, 9 Jan 2017 12:15:12 -0800
Message-ID: <20170109121512.071847c6@xeon-e3>
References: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33360 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932551AbdAIUPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:15:20 -0500
Received: by mail-pf0-f172.google.com with SMTP id y143so12259114pfb.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 12:15:20 -0800 (PST)
In-Reply-To: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  5 Jan 2017 16:22:20 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> David Ahern (3):
>   ip vrf: Fix error message when running exec as non-root user
>   ip vrf: Improve error message for non-root user
>   ip vrf: Clean up bpf related error messages
> 
>  ip/ipvrf.c |  6 +++++-
>  lib/fs.c   | 16 ++++++++++++----
>  2 files changed, 17 insertions(+), 5 deletions(-)
> 

Looks good, applied.
