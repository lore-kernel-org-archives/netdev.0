From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 13:27:20 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.132720.22019247.davem@redhat.com>
References: <3EEF7030.6030303@us.ibm.com>
	<20030617.125040.58438649.davem@redhat.com>
	<3EEF78F4.2070604@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, shemminger@osdl.org, Valdis.Kletnieks@vt.edu,
   girouard@us.ibm.com, stekloff@us.ibm.com, lkessler@us.ibm.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janiceg@us.ibm.com
In-Reply-To: <3EEF78F4.2070604@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Janice M Girouard <janiceg@us.ibm.com>
   Date: Tue, 17 Jun 2003 15:24:20 -0500
   
   Perhaps if RDMA is  capabilities are added to Linux, then things
   might be different.
   
   So.. when do you think RDMA will show up on Linx?

RDMA is total junk.

On RX, clever RX buffer management is what we need.

On TX zerocopy + TSO is more than sufficient and we have
that today.
