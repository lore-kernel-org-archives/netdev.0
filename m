From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]  802.1q vlan updates
Date: Thu, 6 Nov 2003 12:46:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031106124659.109c0d5c.davem@redhat.com>
References: <3FA9CD0B.8000707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3FA9CD0B.8000707@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 05 Nov 2003 20:24:43 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Here is a patch that is a cleaned up version of something I sent
> a while back.  This adds the ability to query a device to see if
> it is a vlan device by asking for the vlan's parent device.
> One can deduce that a querried interface is not a VLAN by looking
> at the IOCTL error code.
> 
> Patch is against 2.4.22-pre9, compile tested and extracted from a run-time
> tested patch.

I'll push this to Marcelo for 2.4.24, thanks.

If you could cook up and test a 2.6.x version, I'll push that in
for 2.6.1
