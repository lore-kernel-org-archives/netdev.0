From: Ben Greear <greearb@candelatech.com>
Subject: ethtool -d no longer works for e1000
Date: Wed, 09 Mar 2005 13:35:51 -0800
Message-ID: <422F6C37.8090202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I tried this with FC2's 2.6.10-1.770_FC2smp kernel and with my own
slightly hacked 2.6.11 kernel.  Both give this response:

ethtool -d eth0
Cannot dump registers:  Success

I am quite certain this used to work, and used to show me
the PCI bus speed and other nice details...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
