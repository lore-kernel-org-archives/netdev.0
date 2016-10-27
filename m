From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]ldmvsw: tx queue stuck in stopped state after
 LDC reset
Date: Wed, 26 Oct 2016 23:11:46 -0400 (EDT)
Message-ID: <20161026.231146.1586712216881878184.davem@davemloft.net>
References: <b8d6abc7188e5cac885905854067444cb89a5f3b.1477503707.git.Aaron.Young@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: Aaron.Young@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752855AbcJ0DLx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 23:11:53 -0400
In-Reply-To: <b8d6abc7188e5cac885905854067444cb89a5f3b.1477503707.git.Aaron.Young@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Young <Aaron.Young@oracle.com>
Date: Wed, 26 Oct 2016 20:15:22 -0400

>    From: Aaron Young <aaron.young@oracle.com>
> 
>    The following patch fixes an issue with the ldmvsw driver where
>    the network connection of a guest domain becomes non-functional after
>    a guest domain has panic'd and rebooted (resulting in a LDC reset).
> 

Please fix this indentation, make this text begin on the
first column of every line.

I bet I know how this got this way, you copy and pasted the
commit message from "git show" output or similar and didn't
remove the indentation that adds.
