From: "David S. Miller" <davem@redhat.com>
Subject: Re: Kernel 2.4.25 + VLAN + CBQ disc broken ?
Date: Wed, 24 Mar 2004 12:05:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040324120551.29254b7c.davem@redhat.com>
References: <4008E74134355D43998FFFC3D637BB030463DF@starsky.ncc.itgate.net>
	<4060C0A5.40402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gf.dellicarri@ncc.itgate.net, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4060C0A5.40402@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Mar 2004 23:56:37 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Dave, the txqueuelen=0 fix for pfifo_fast apparently didn't went in
> 2.4, this is the patch from 2.6, it applies with minor offset.

Indeed, thanks Patrick I've applied this.
