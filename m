From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Always copy and save the vlan header in bridge-nf
Date: Mon, 29 Dec 2003 17:52:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031229175243.23c33000.davem@redhat.com>
References: <200312271450.18115.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312271450.18115.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 27 Dec 2003 14:50:18 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> We should also filter vlan-tagged IP/ARP traffic even if the vlan code
> isn't compiled into the kernel. The patch below removes an unnecessary
> dependence on the vlan code being compiled.

Applied, thanks Bart.
