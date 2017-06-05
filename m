From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 V2] iplink: Update usage in help message
Date: Mon, 5 Jun 2017 12:30:00 -0700
Message-ID: <20170605123000.648ff445@xeon-e3>
References: <1496579808-31933-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Eli Cohen <eli@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36660 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751077AbdFETaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:30:03 -0400
Received: by mail-pg0-f53.google.com with SMTP id a70so17458231pge.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:30:03 -0700 (PDT)
In-Reply-To: <1496579808-31933-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  4 Jun 2017 15:36:48 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

> From: Eli Cohen <eli@mellanox.com>
> 
> Add to usage message a description of how to configure Infiniband node
> and port GUIDs. Also modify the man page to emphasize the GUIDs are
> configured for Infiniband VFs.
> 
> Fixes: d91fb3f4c7e4 ("Add support for configuring Infiniband GUIDs")
> Signed-off-by: Eli Cohen <eli@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Looks good, applied
