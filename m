From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] net: display hw address of source machine during
 ipv6 DAD failure
Date: Mon, 30 Oct 2017 14:53:11 -0600
Message-ID: <fb3f6260-f227-9abc-522b-fa1baf8fa550@gmail.com>
References: <1509395380-28057-1-git-send-email-vpai@akamai.com>
 <2aa97226-9db7-e401-3e90-7c773e1e083b@gmail.com>
 <5a65d720-37f3-3d83-afbe-d5e69400ec83@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilubashe@akamai.com, pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:46477 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932915AbdJ3UxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 16:53:14 -0400
Received: by mail-pg0-f50.google.com with SMTP id k7so12698740pga.3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 13:53:13 -0700 (PDT)
In-Reply-To: <5a65d720-37f3-3d83-afbe-d5e69400ec83@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/17 2:50 PM, Vishwanath Pai wrote:
> It does print out the full uncompressed IPv6 address. I modified the
> message manually by hand while copying it out to the commit message in
> order to hide the real IP address of my machines, but did not realize
> that it was different from what the kernel would actually print out.

use 2001:db8::/32 (https://tools.ietf.org/html/rfc3849)
