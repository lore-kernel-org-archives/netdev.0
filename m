From: Ben Greear <greearb@candelatech.com>
Subject: How to count tx and rx bytes?
Date: Mon, 15 Dec 2003 12:03:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FDE13AE.3050402@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Is there an agreed upon standard for exactly what ethernet drivers
should be counting for rx-bytes and tx-bytes?  For example, should the
counters include the 4-byte FCS?  Should they include the ethernet header?

 From what I can tell, various drivers count the rx and tx bytes differently,
which cannot be correct....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
