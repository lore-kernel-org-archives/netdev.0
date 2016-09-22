From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: Use specific slave id
Date: Thu, 22 Sep 2016 16:40:47 -0700
Message-ID: <20160922164047.1180acad@xeon-e3>
References: <1474365732-6087-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33307 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965220AbcIVXki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:40:38 -0400
Received: by mail-pf0-f179.google.com with SMTP id 21so35350239pfy.0
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 16:40:38 -0700 (PDT)
In-Reply-To: <1474365732-6087-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 18:02:12 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> The original bond/bridge/vrf and slaves use same id, which make people
> confused. Use bond/bridge/vrf_slave as id name will make code more clear.
> 
> Acked-by: Phil Sutter <psutter@redhat.com>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---

Applied
