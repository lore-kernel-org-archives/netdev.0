From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2] ipvtap: Adding support for ipvtap device
 management
Date: Tue, 30 May 2017 17:47:05 -0700
Message-ID: <20170530174705.3be933e8@xeon-e3>
References: <1495581725-10829-1-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sainath Grandhi <sainath.grandhi@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35730 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdEaArS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:47:18 -0400
Received: by mail-pf0-f171.google.com with SMTP id n23so2009987pfb.2
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:47:18 -0700 (PDT)
In-Reply-To: <1495581725-10829-1-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 May 2017 16:22:05 -0700
Sainath Grandhi <sainath.grandhi@intel.com> wrote:

> This patch adds support for managing ipvtap devices using ip link. ipvtap support
> is added to linux with commit 235a9d89da976e2975b3de9afc0bed7b72557983

Please resend with a Signed-off-by line.

Also, you need to update the Usage message and the man page.
