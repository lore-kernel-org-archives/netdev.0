From: Ben Greear <greearb@candelatech.com>
Subject: e100 and bad CRC packets.
Date: Thu, 13 Nov 2003 01:28:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB34EC9.1000003@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is there a way to make the e100 (and/or e1000) driver pass packets
with bad CRC up the stack so that they could be passed to tcpdump
or a raw packet socket?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
