From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bridge] Re: [PATCH/RFC] Let {ip, arp}tables "see" bridged VLAN
 tagged {I, AR}P packets
Date: Tue, 7 Oct 2003 13:22:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007132226.5ac7a184.shemminger@osdl.org>
References: <200310062204.07230.bdschuym@pandora.be>
	<20031007080640.50de4d45.davem@redhat.com>
	<200310072112.53821.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        greearb@candelatech.com, bridge@osdl.org, vlan@wanfear.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200310072112.53821.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On
> >
> > Once you fix that I'll apply your patch as long as Stephen has no
> > objections.

Looks fine to me, there are some things that might want to be cleaned up,
 but they can go in later.
