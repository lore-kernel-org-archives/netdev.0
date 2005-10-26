From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation offload
 support
Date: Wed, 26 Oct 2005 00:53:09 -0400
Message-ID: <435F0BB5.1070802@pobox.com>
References: <432D7354.8000503@colorfullife.com>	<43595C42.4080201@pobox.com>	<435D1047.2070401@nvidia.com> <20051024110003.53e37edd@dxpl.pdx.osdl.net> <435D1464.3010203@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        Manfred Spraul <manfred@colorfullife.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <435D1464.3010203@nvidia.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> Yes, forgot that indent.
> 
> Here it is again with that fix.

I applied this version of the patch to the 'upstream' patch.

In the future, as Stephen noted, it would really be preferred that you 
split up the patch into logical changes.  patch 1/2 netdev_priv(), patch 
2/2 SG support, for example.

Also, always include the Signed-off-by line, even on patch resends.  See
	http://linux.yyz.us/patch-format.html
for more info.

	Jeff
