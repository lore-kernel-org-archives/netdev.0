From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: Trigger state machine on state
 change and not polling.
Date: Thu, 13 Oct 2016 12:30:59 -0400 (EDT)
Message-ID: <20161013.123059.555986955599323943.davem@davemloft.net>
References: <1476303294-14944-1-git-send-email-andrew@lunn.ch>
        <20161013.120438.1184858529653754916.davem@davemloft.net>
        <20161013162901.GA1286@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, kyle.roeschley@ni.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757069AbcJMQbE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 12:31:04 -0400
In-Reply-To: <20161013162901.GA1286@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 13 Oct 2016 18:29:01 +0200

> Just for my clarification:
> 
> We are in the middle of the merge window. What does net-next and net
> mean at the moment?

Once I merge net-next to Linus, bug fixes should go to 'net'.

And for the past day or so I've been slowly merging new features and
cleanups into 'net-next'.  I realize that this latter aspect is a
departure from the past, but no matter how hard I try people still
submit net-next things during the merge window so I've basically given
up pushing back on that.
