From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] two small fixes in flower option parser
 error flow
Date: Fri, 20 Jan 2017 09:30:15 -0800
Message-ID: <20170120093015.2c0f06a9@xeon-e3>
References: <1484829080-18593-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Paul Blakey <paulb@mellanox.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34835 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752425AbdATRaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:30:23 -0500
Received: by mail-pf0-f178.google.com with SMTP id f144so23909470pfa.2
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:30:22 -0800 (PST)
In-Reply-To: <1484829080-18593-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 14:31:18 +0200
Roi Dayan <roid@mellanox.com> wrote:

> Hi,
> 
> the first adds a missing return check and the second removes
> an incorrect error msg.
> 
> Thanks,
> Roi
> 
> 
> Roi Dayan (2):
>   tc: flower: Add missing err check when parsing flower options
>   tc: flower: Fix incorrect error msg about eth type
> 
>  tc/f_flower.c |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)
> 

Both applied
