From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] fix netlink message length checks
Date: Sun, 9 Oct 2016 18:59:19 -0700
Message-ID: <20161009185919.22feb630@xeon-e3>
References: <1475576215-9829-1-git-send-email-iryzhov@nfware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Igor Ryzhov <iryzhov@nfware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36541 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751516AbcJJB7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 21:59:04 -0400
Received: by mail-pa0-f51.google.com with SMTP id ry6so45607549pac.3
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 18:59:04 -0700 (PDT)
In-Reply-To: <1475576215-9829-1-git-send-email-iryzhov@nfware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Oct 2016 13:16:55 +0300
Igor Ryzhov <iryzhov@nfware.com> wrote:

> Signed-off-by: Igor Ryzhov <iryzhov@nfware.com>

Makes sense applied, I wonder why one of the static checkers didn't see this.
