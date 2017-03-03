From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 1/1] color: use "light" colors for dark
 background
Date: Fri, 3 Mar 2017 09:59:19 -0800
Message-ID: <20170303095919.60bc39af@xeon-e3>
References: <20170301205233.27624-1-pvorel@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mathias Nyman <m.nyman@iki.fi>,
        Yegor Yefremov <yegorslists@googlemail.com>
To: Petr Vorel <pvorel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35306 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdCCSHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 13:07:30 -0500
Received: by mail-pf0-f172.google.com with SMTP id j5so35600724pfb.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 10:06:04 -0800 (PST)
In-Reply-To: <20170301205233.27624-1-pvorel@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  1 Mar 2017 21:52:33 +0100
Petr Vorel <pvorel@suse.cz> wrote:

> COLORFGBG environment variable is used to detect dark background.
> 
> Idea and a bit of code is borrowed from Vim, thanks.
> 
> Signed-off-by: Petr Vorel <pvorel@suse.cz>

Applied and I split one long line.
