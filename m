From: Ben Greear <greearb@candelatech.com>
Subject: Function to determine if IP exists on a net-device?
Date: Wed, 19 Nov 2003 01:25:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBB36F2.7030402@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is there a method already written that will tell me if an IP exists on
a netdevice?

If not, I am quite sure the answer lies in the in_ifaddr
list, but which field holds the IP address for the device?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
