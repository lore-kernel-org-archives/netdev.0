From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Wed, 11 Sep 2002 08:15:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020911.081521.103561835.davem@redhat.com>
References: <m1hegwoppm.fsf@frodo.biederman.org>
	<477096648.1031728254@[10.10.2.3]>
	<m1d6rko9ab.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbligh@aracnet.com, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ebiederm@xmission.com
In-Reply-To: <m1d6rko9ab.fsf@frodo.biederman.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: ebiederm@xmission.com (Eric W. Biederman)
   Date: 11 Sep 2002 09:06:36 -0600

   "Martin J. Bligh" <mbligh@aracnet.com> writes:
   
   > We can push about 420MB/s of IO out of this thing (out of that 
   > theoretical 800Mb/s). 
   
   Sounds about average for a P3.  I have pushed the full 800MiB/s out of
   a P3 processor to memory but it was a very optimized loop.

You pushed that over the PCI bus of your P3?  Just to RAM
doesn't count, lots of cpu's can do that.

That's what makes his number interesting.
