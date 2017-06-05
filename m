From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V7 net-next iproute] ip: Add IFLA_EVENT output to ip
 monitor
Date: Mon, 5 Jun 2017 12:38:40 -0700
Message-ID: <20170605123840.3f4f102f@xeon-e3>
References: <1496329276-31106-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: Vladislav Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33462 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751178AbdFETis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:38:48 -0400
Received: by mail-pf0-f182.google.com with SMTP id 83so29807801pfr.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:38:47 -0700 (PDT)
In-Reply-To: <1496329276-31106-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Jun 2017 11:01:16 -0400
Vladislav Yasevich <vyasevic@redhat.com> wrote:

> Add IFLA_EVENT output so that event types can be viewed with
> 'monitor' command.  This gives a little more information for why
> a given message was received.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied to net-next.
