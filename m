From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-next 00/27] Remove VLAN CFI bit abuse
Date: Tue, 13 Dec 2016 06:18:43 +0100
Message-ID: <20161213051843.z7lgg34vjdg542w7@rere.qmqm.pl>
References: <cfa1f2efae2217b50cbefccbf9ba7f0d24a23c63.1480755768.git.mirq-linux@rere.qmqm.pl>
 <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:54134 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbcLMFSq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 00:18:46 -0500
Content-Disposition: inline
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 01:12:32AM +0100, Micha³ Miros³aw wrote:
> Dear NetDevs
> 
> This series removes an abuse of VLAN CFI bit in Linux networking stack.
> Currently Linux always clears the bit on outgoing traffic and presents
> it cleared to userspace (even via AF_PACKET/tcpdump when hw-accelerated).
[...]

I just noticed net-next got closed few days ago. I'll resend after it
opens again.  Nevertheless, review is appreciated.

Best Regards,
Micha³ Miros³aw
