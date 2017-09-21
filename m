From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ip: ipaddress: fix missing space after
 prefixlen
Date: Wed, 20 Sep 2017 18:06:02 -0700
Message-ID: <20170920180602.5ffa162d@xeon-e3>
References: <20170920202651.95860-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com,
        sd@queasysnail.net
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:56767 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbdIUBGF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 21:06:05 -0400
Received: by mail-pg0-f53.google.com with SMTP id 7so2633511pgd.13
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 18:06:05 -0700 (PDT)
In-Reply-To: <20170920202651.95860-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Sep 2017 13:26:51 -0700
Julien Fortin <julien@cumulusnetworks.com> wrote:

> From: Julien Fortin <julien@cumulusnetworks.com>
> 
> Fixes: d0e720111aad2 ("ip: ipaddress.c: add support for json output")
> Reported-by: Sabrina Dubroca <sd@queasysnail.net>
> Reviewed-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>

Applied, thanks for spotting this.
