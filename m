From: Ben Greear <greearb@candelatech.com>
Subject: Re: Fw: [Bugme-new] [Bug 3657] New: downed interfaces acting as aliases
Date: Fri, 29 Oct 2004 00:28:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4181F12F.7060400@candelatech.com>
References: <20041028234649.2d4ed3b8.akpm@osdl.org>	<20041028234502.203b42c3.davem@davemloft.net>	<4181ED02.1060501@candelatech.com> <20041029000651.6fd7360f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, mbm@alt.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041029000651.6fd7360f.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 29 Oct 2004 00:10:58 -0700

> People hate it that when there's a decision of whether to
> reply to something or not, we do whatever we can to reply
> to packets we receive if we can find a way to do so.  This
> approache increases the likelyhood that two hosts can
> communicate successfully.  I need not remind people about
> how much people dislike our default ARP behavior :-) but
> it is done that way for the same reason.

Note I was distictly kind enough not to bring it up either :)
(I have already patched & hacked around that problem some years ago!)

Since you finally accepted the arp fixup, maybe you'd at least let
in a flag to change the default behaviour of downed interfaces too?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
