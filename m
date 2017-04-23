From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: Expose IFLA_*_FWMARK attributes for
 supported link types
Date: Sun, 23 Apr 2017 09:16:10 -0700
Message-ID: <20170423091610.145ed24a@xeon-e3>
References: <20170421181453.166316-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36620 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161972AbdDWQQN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 12:16:13 -0400
Received: by mail-io0-f181.google.com with SMTP id p80so41413739iop.3
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 09:16:13 -0700 (PDT)
In-Reply-To: <20170421181453.166316-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Apr 2017 14:14:53 -0400
Craig Gallek <kraigatgoog@gmail.com> wrote:

> From: Craig Gallek <kraig@google.com>
> 
> This attribute allows the administrator to adjust the packet marking
> attribute of tunnels that support policy based routing.
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied to net-next. Since the link attributes are not in 4.11
