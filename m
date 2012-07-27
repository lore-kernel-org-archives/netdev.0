From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH iproute2] ss: report SK_MEMINFO_BACKLOG
Date: Thu, 26 Jul 2012 17:29:26 -0700
Message-ID: <CAGK4HS-fUp2ZiW9F_ZogOXQo5_2ptcBHT9Y2j25ZaoXrYKnbAQ@mail.gmail.com>
References: <1343294420.2626.11264.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:43640 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab2G0A31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 20:29:27 -0400
Received: by obbuo13 with SMTP id uo13so3452917obb.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 17:29:27 -0700 (PDT)
In-Reply-To: <1343294420.2626.11264.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 July 2012 02:20, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> linux-3.6-rc1 supports SK_MEMINFO_BACKLOG with commit d594e987c6f54
> (sock_diag: add SK_MEMINFO_BACKLOG)
>
> ss command can display it if provided by the kernel.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Vijay Subramanian <subramanian.vijay@gmail.com>


Thanks Eric. I see now how you fixed this.

Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Vijay
