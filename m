From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2] man: tc-csum.8: Fix example
Date: Sun, 29 Jan 2017 20:26:09 -0800
Message-ID: <20170129202609.6b2521a0@xeon-e3>
References: <20170128115910.1127-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35520 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751281AbdA3E0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 23:26:12 -0500
Received: by mail-pg0-f51.google.com with SMTP id 194so97630319pgd.2
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 20:26:12 -0800 (PST)
In-Reply-To: <20170128115910.1127-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Jan 2017 12:59:10 +0100
Phil Sutter <phil@nwl.cc> wrote:

> This fixes two issues with the provided example:
> 
> - Add missing 'dev' keyword to second command.
> - Use a real IPv4 address instead of a bogus hex value since that will
>   be rejected by get_addr_ipv4().
> 
> Fixes: dbfb17a67f9c7 ("man: tc-csum.8: Add an example")
> Reported-by: Davide Caratti <dcaratti@redhat.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v1:
> - Instead of using potentially valid IP addresses, use RFC 5737 ones.

Applied thanks
