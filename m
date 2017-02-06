From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] man: ip-route.8: Fix 'expires' indenting
Date: Mon, 6 Feb 2017 13:53:11 -0800
Message-ID: <20170206135311.58ed4060@xeon-e3>
References: <20170202152256.25191-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35874 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751372AbdBFVxS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:53:18 -0500
Received: by mail-pg0-f42.google.com with SMTP id v184so31784584pgv.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:53:18 -0800 (PST)
In-Reply-To: <20170202152256.25191-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  2 Feb 2017 16:22:56 +0100
Phil Sutter <phil@nwl.cc> wrote:

> Descriptions of each route sub-command's arguments are enclosed in
> .RS/.RE pairs. For 'replace' sub-command, '.RE' was incorrectly put
> before the last argument ('expires').
> 
> Fixes: 3fbe7ca847367 ("iproute2: ip-route.8.in: Add expires option for ip route")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, thanks
