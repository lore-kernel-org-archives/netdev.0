From: David Vrabel <dvrabel@cantab.net>
Subject: Re: [Xen-devel] [PATCH v2 net-next 7/7] xen/netback: add fraglist
 support for to-guest rx
Date: Tue, 4 Oct 2016 11:56:39 +0100
Message-ID: <958f3f57-8e8a-5e51-77d3-25efdf10fee0@cantab.net>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-8-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ross Lagerwall <ross.lagerwall@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>, netdev@vger.kernel.org,
        xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36613 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbcJDK4m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 06:56:42 -0400
Received: by mail-wm0-f65.google.com with SMTP id b184so19052419wma.3
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 03:56:41 -0700 (PDT)
In-Reply-To: <1475573358-32414-8-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/16 10:29, Paul Durrant wrote:
> From: Ross Lagerwall <ross.lagerwall@citrix.com>
> 
> This allows full 64K skbuffs (with 1500 mtu ethernet, composed of 45
> fragments) to be handled by netback for to-guest rx.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
