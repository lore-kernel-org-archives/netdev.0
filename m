From: "David S. Miller" <davem@redhat.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 14:44:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627.144426.71096593.davem@redhat.com>
References: <18330000.1056692768@[10.10.2.4]>
	<20030626.224739.88478624.davem@redhat.com>
	<3EFC9203.3090508@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbligh@aracnet.com, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EFC9203.3090508@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Fri, 27 Jun 2003 11:50:43 -0700

   It would also keep bugs from falling through the cracks:

People DON'T understand.  I _WANT_ them to be able to
fall through the cracks.

If it's important, people will retransmit.

This work for kernel patches, and has so for over 5 years.
So what makes anyone thing it doesn't work for bug reporting?
