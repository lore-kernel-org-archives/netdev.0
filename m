From: Andre Tomt <andre@tomt.net>
Subject: Re: ethtool -d no longer works for e1000
Date: Wed, 09 Mar 2005 23:59:40 +0100
Message-ID: <422F7FDC.2090202@tomt.net>
References: <422F6C37.8090202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <422F6C37.8090202@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I tried this with FC2's 2.6.10-1.770_FC2smp kernel and with my own
> slightly hacked 2.6.11 kernel.  Both give this response:
> 
> ethtool -d eth0
> Cannot dump registers:  Success
> 
> I am quite certain this used to work, and used to show me
> the PCI bus speed and other nice details...

Works fine here. Only thing is that CSA adapters seems to come up as 
32bit 33Mhz PCI.
