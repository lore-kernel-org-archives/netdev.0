From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Always copy and save the vlan header in bridge-nf (do
 it right now)
Date: Wed, 31 Dec 2003 10:32:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031231103238.6067a575.davem@redhat.com>
References: <200312311156.11241.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, szepe@pinerecords.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312311156.11241.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Dec 2003 11:56:11 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> I forgot to get rid of another ifdef in netfilter_bridge.h when I removed
> the dependency upon vlan being compiled. This patch fixes it.

Applied, thanks Bart.
