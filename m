From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2.6] (2/3) vlan propogate carrier and hotplug state
Date: Tue, 03 Aug 2004 13:53:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FFB3D.7070002@candelatech.com>
References: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>	<410FD348.9040301@candelatech.com> <20040803134014.7164280c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803134014.7164280c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The bridge STP code now wants to handle device's getting connected/disconnected
> and this includes vlan devices.  This patch makes the VLAN pseudo device state
> mirror the state of the real device.  Only bothered with carrier and hotplug.

Ok by me.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
