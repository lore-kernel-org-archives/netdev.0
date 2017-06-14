From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] link_gre6: really support encaplimit option
Date: Wed, 14 Jun 2017 13:31:18 -0700
Message-ID: <20170614133118.482b3c59@xeon-e3>
References: <1497458742-6068-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35831 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752647AbdFNUbf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 16:31:35 -0400
Received: by mail-pf0-f172.google.com with SMTP id l89so5610450pfi.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 13:31:35 -0700 (PDT)
In-Reply-To: <1497458742-6068-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 18:45:42 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> This option is documented in gre6 help, but was not supported.
> 
> Fixes: af89576d7a8c ("iproute2: GRE over IPv6 tunnel support.")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Sure applied.
