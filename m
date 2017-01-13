From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: tcp: performance issue with fastopen connections (mss > window)
Date: Fri, 13 Jan 2017 17:58:49 +0300
Message-ID: <ee4ee3b0-81b7-e31b-ef4d-b6e4488d9cfe@oracle.com>
References: <5878E166.8080800@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vasily Isaenko <vasily.isaenko@oracle.com>
To: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18015 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdAMO7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 09:59:07 -0500
In-Reply-To: <5878E166.8080800@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.01.2017 17:17, Alexey Kodanev wrote:
> Hi,
>
> Got the issue when running LTP/netstress test on localhost with mss
> greater than the send window advertised by client (right after 3WHS).
> Here is the testscenario that can reproduce this:

Please ignore this message with 'flowed' format. Will resend.

Thanks,
Alexey
