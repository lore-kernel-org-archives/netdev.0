From: "David S. Miller" <davem@redhat.com>
Subject: Re: (usagi-core 12294) Re: [PATCH] IPv6 IPsec support
Date: Thu, 06 Mar 2003 15:27:03 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030306.152703.21845381.davem@redhat.com>
References: <20030306.004820.41101302.yoshfuji@linux-ipv6.org>
	<20030305.154100.28816301.davem@redhat.com>
	<20030306213217.GA6358@f00f.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kazunori@miyazawa.org, kuznet@ms2.inr.ac.ru,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: cw@f00f.org
In-Reply-To: <20030306213217.GA6358@f00f.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Chris Wedgwood <cw@f00f.org>
   Date: Thu, 6 Mar 2003 13:32:17 -0800
   
   Actually... at that point being able to monitor updates to the
   flow-cache would be useful for various statistical purposes and
   applications, especially if the flow cache was able to periodically
   export utilization counters...
   
It will keep statistics, just like the route cache keeps
them now.
   
