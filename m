From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] tc-simple: Fix documentation
Date: Thu, 3 Aug 2017 16:03:04 -0700
Message-ID: <20170803160304.2c256bee@xeon-e3>
References: <20170803150051.19741-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:37714 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdHCXDI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:03:08 -0400
Received: by mail-pg0-f45.google.com with SMTP id y129so434433pgy.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:03:08 -0700 (PDT)
In-Reply-To: <20170803150051.19741-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Aug 2017 17:00:51 +0200
Phil Sutter <phil@nwl.cc> wrote:

> - CONTROL has to come last, otherwise 'index' applies to gact and not
>   simple itself.
> - Man page wasn't updated to reflect syntax changes.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applid, thanks Phil
