From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:13:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.151308.55864910.davem@redhat.com>
References: <3EEE28DE.6040808@us.ibm.com>
	<3EEE40F1.4030107@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: janiceg@us.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   stekloff@us.ibm.com, girouard@us.ibm.com, lkessler@us.ibm.com,
   kenistonj@us.ibm.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <3EEE40F1.4030107@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Mon, 16 Jun 2003 15:13:05 -0700
   
   I'd certainly like to see messages from the driver when the
   card enters/leaves promiscuous mode,

egrep "promiscuous mode" net/core/dev.c | grep printk
