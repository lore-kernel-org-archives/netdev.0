From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Makefile: really suppress printing of
 directories
Date: Fri, 9 Dec 2016 12:50:32 -0800
Message-ID: <20161209125032.57af6e8e@xeon-e3>
References: <1481144109-11116-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36332 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbcLIUuk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 15:50:40 -0500
Received: by mail-pg0-f51.google.com with SMTP id f188so11297243pgc.3
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 12:50:39 -0800 (PST)
In-Reply-To: <1481144109-11116-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Dec 2016 12:55:09 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> Makefile adds --no-print-directory to MAKEFLAGS if VERBOSE is not
> defined however Config always defines VERBOSE. Update the check to
> whether VERBOSE is 0.
> 
> Fixes: 57bdf8b76451 ("Make builds default to quiet mode")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied to net-next.

Patch only works with net-next, please label it next time.
