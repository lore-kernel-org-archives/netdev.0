From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Sun, 25 Jul 2004 23:56:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41042CA3.2050702@trash.net>
References: <40F34740.5040100@trash.net>	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>	<20040712205037.573411c0.davem@redhat.com>	<40F4862D.3070802@trash.net>	<40F4AC8B.40706@trash.net>	<20040721143110.4ab944bf.davem@redhat.com>	<41004F76.1080807@trash.net>	<20040722171752.341d2476.davem@redhat.com>	<41006150.9000702@trash.net>	<41014788.4070301@trash.net>	<20040723135459.2ee5c42c.davem@redhat.com>	<41019CDA.9050401@trash.net> <20040724232705.237396b4.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040724232705.237396b4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Let me know if you get feedback or not.
> 
> For now I'm pushing to Linus with Alpha removed from the
> list.

According to Richard Henderson it should work fine. The fastest
Alpha cycle counter (1.2 GHz) takes 3.57 seconds to overflow.

Regards
Patrick
