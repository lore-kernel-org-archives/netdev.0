From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/10] [bonding 2.6] port 2.4 bug fixes to 2.6
Date: Thu, 11 Sep 2003 14:55:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F60C524.5070904@pobox.com>
References: <200309042043.25567.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Amir Noam <amir.noam@intel.com>
In-Reply-To: <200309042043.25567.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Amir Noam wrote:
> The following set ports to 2.6 numerous bug fixes that went into
> 2.4 recently. Patches apply on 2.6.0-test4. Compile tested only.
> 
> patch1:  fix 802.3ad long fail over with high UDP Tx stress
> patch2:  fix load balance problem with high UDP Tx stress
> patch3:  fix ARP monitoring bug
> patch4:  fix kernel panic when optional feature used
> patch5:  fix change active command
> patch6:  fix OOPS in bonding driver, when removing primary
> patch7:  embed stats struct inside bonding private struct
> patch8:  fix error handling in init code
> patch9:  make each bond device use its own /proc entry
> patch10: misc fixes: missing include, typos, comments
> 

All patches in this series applied.

	Jeff
