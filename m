From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv4: update comment to document GSO
 fragmentation cases.
Date: Thu, 10 Nov 2016 12:02:38 -0500 (EST)
Message-ID: <20161110.120238.1571377299529074321.davem@davemloft.net>
References: <1478721879-11033-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34516 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934375AbcKJRCk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 12:02:40 -0500
In-Reply-To: <1478721879-11033-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Wed,  9 Nov 2016 15:04:39 -0500

> This is a follow-up to commit 9ee6c5dc816a ("ipv4: allow local
> fragmentation in ip_finish_output_gso()"), updating the comment
> documenting cases in which fragmentation is needed for egress
> GSO packets.
> 
> Suggested-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---
> v2: corrected commit ID (v1 used local commit ID by mistake)

Applied.
