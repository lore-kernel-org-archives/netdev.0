From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bridge] RE: [VLAN] Re: [PATCH/RFC] Let {ip, arp}tables "see"
 bridged VLAN tagged{I,AR}P packets
Date: Wed, 8 Oct 2003 08:58:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008085859.28750553.davem@redhat.com>
References: <5B537508CDBED3118403009027745A210B8C1499@knant18.kna.flextronics.com>
	<1065600565.2572.209.camel@cyan.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christian.Darnell@se.flextronics.com, vlan@wanfear.com,
        bdschuym@pandora.be, netdev@oss.sgi.com, bridge@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <1065600565.2572.209.camel@cyan.cph.tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 08 Oct 2003 10:09:25 +0200
Tommy Christensen <tommy.christensen@tpack.net> wrote:

> This is because the VLAN code is mangling shared data.
> You need to do something like this:

This fix is definitely needed and correct, patch applied
thanks.
