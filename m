From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 11:36:52 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906.113652.40767574.davem@redhat.com>
References: <3D78E7A5.7050306@us.ibm.com>
	<20020906202646.A2185@wotan.suse.de>
	<3D78F4E6.3020101@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, Martin.Bligh@us.ibm.com, hadi@cyberus.ca,
   tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: haveblue@us.ibm.com
In-Reply-To: <3D78F4E6.3020101@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Dave Hansen <haveblue@us.ibm.com>
   Date: Fri, 06 Sep 2002 11:33:10 -0700
   
   Actually, oprofile separated out the acenic module from the rest of the 
   kernel.  I should have included that breakout as well. but it was only 1.3 
   of CPU:
   1.3801 0.0000 /lib/modules/2.4.18+O1/kernel/drivers/net/acenic.o

We thought you were using e1000 in these tests?
