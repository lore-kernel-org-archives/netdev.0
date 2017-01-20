From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre6: Clean up unused struct
 ipv6_tel_txoption definition
Date: Fri, 20 Jan 2017 11:37:14 -0500 (EST)
Message-ID: <20170120.113714.1859127019240221345.davem@davemloft.net>
References: <1484920386-9058-1-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753131AbdATQhQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:37:16 -0500
In-Reply-To: <1484920386-9058-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Fri, 20 Jan 2017 14:53:06 +0100

> Commit b05229f44228 ("gre6: Cleanup GREv6 transmit path, call common GRE
> functions") removed the ip6gre specific transmit function, but left the
> struct ipv6_tel_txoption definition. Clean it up.
> 
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Applied, thank you.
