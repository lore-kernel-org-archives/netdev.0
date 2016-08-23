From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next] net: diag: support SOCK_DESTROY for UDP
 sockets
Date: Mon, 22 Aug 2016 22:13:01 -0600
Message-ID: <015066f2-6df8-ab39-d4b7-632c9e8e2fc0@cumulusnetworks.com>
References: <1471914221-24213-1-git-send-email-dsa@cumulusnetworks.com>
 <1471918541.14381.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33718 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751401AbcHWENE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 00:13:04 -0400
Received: by mail-pa0-f51.google.com with SMTP id ti13so43981058pac.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 21:13:04 -0700 (PDT)
In-Reply-To: <1471918541.14381.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/22/16 8:15 PM, Eric Dumazet wrote:
> Hi David
> 
> It seems you forgot the sock_diag_check_cookie() call, but other than
> that this patch looks fine.
> 
> Thanks.


indeed. will fix tomorrow and re-send. Thanks for the review.
