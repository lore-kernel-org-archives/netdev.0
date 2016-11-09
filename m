From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: update comment to document GSO fragmentation
 cases.
Date: Wed, 09 Nov 2016 12:46:39 -0500 (EST)
Message-ID: <20161109.124639.1288097141272366697.davem@davemloft.net>
References: <1478276558-10974-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbcKIRqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 12:46:42 -0500
In-Reply-To: <1478276558-10974-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Fri,  4 Nov 2016 12:22:38 -0400

> This is a follow-up to commit eb96202f1e34 ("ipv4: allow local
> fragmentation in ip_finish_output_gso()"), updating the comment
> documenting cases in which fragmentation is needed for egress
> GSO packets.
> 
> Suggested-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

That commit ID doesn't look right.  It should be 9ee6c5dc816a
