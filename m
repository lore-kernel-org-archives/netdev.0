From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 15:57:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.155717.58468888.davem@redhat.com>
References: <3EEE40F1.4030107@us.ibm.com>
	<20030616.151308.55864910.davem@redhat.com>
	<3EEE49BA.6070401@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: janiceg@us.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   stekloff@us.ibm.com, girouard@us.ibm.com, lkessler@us.ibm.com,
   kenistonj@us.ibm.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <3EEE49BA.6070401@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Mon, 16 Jun 2003 15:50:34 -0700

   I do see positives in the feature as a whole though.

Would you design a network protocol this way?  By passing
strings like "open connection please", "sure no problem"
back and forth between server and client?

Of course not.

So why are we even remotely considering the standardization
of _STRINGS_ for event reporting?
