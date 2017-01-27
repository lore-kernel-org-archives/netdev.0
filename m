From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [iproute PATCH] man: tc-csum.8: Fix example
Date: Fri, 27 Jan 2017 13:26:06 +0100
Message-ID: <20170127122606.GA2386@nanopsycho>
References: <20170127111501.21439-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:33637 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932691AbdA0MfS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 07:35:18 -0500
Received: by mail-wj0-f194.google.com with SMTP id un2so5876359wjb.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 04:33:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170127111501.21439-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 27, 2017 at 12:15:01PM CET, phil@nwl.cc wrote:
>This fixes two issues with the provided example:
>
>- Add missing 'dev' keyword to second command.
>- Use a real IPv4 address instead of a bogus hex value since that will
>  be rejected by get_addr_ipv4().
>
>Fixes: dbfb17a67f9c7 ("man: tc-csum.8: Add an example")
>Reported-by: Davide Caratti <dcaratti@redhat.com>
>Signed-off-by: Phil Sutter <phil@nwl.cc>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
