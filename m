From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v1 1/2] iproute2: avoid exit in case of error.
Date: Tue, 29 Nov 2016 12:46:55 -0800
Message-ID: <20161129124655.3be4f948@samsung9>
References: <1478890537-88715-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: David Decotigny <ddecotig@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33421 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbcK2Uq6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:46:58 -0500
Received: by mail-pg0-f46.google.com with SMTP id 3so73272739pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:46:58 -0800 (PST)
In-Reply-To: <1478890537-88715-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Nov 2016 10:55:36 -0800
David Decotigny <ddecotig@gmail.com> wrote:

> Be consistent with how non-0 print_route() return values are handled
> elesewhere: return -1.
> 
> 
> ---
>  ip/iproute.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Applied, and queued for next push.
Please use Signed-off-by: on future patches.
