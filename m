From: Ben Greear <greearb@candelatech.com>
Subject: IPv6 messes up VLAN device references.
Date: Wed, 04 May 2005 10:09:52 -0700
Message-ID: <427901E0.6010502@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am seeing lots of reports of being unable to remove vlan
interfaces, and so far the problem is always resolved when
IPv6 is disabled completely.

You can find the bug report here in my vlan bug tracker
if you want the details.

http://grok.yi.org/~greear/bugzilla/show_bug.cgi?id=190

Is there a better place than netdev to submit bugs to the IPv6
people?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
