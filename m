From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 11:48:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906.114815.127906065.davem@redhat.com>
References: <20020906.113611.102227888.davem@redhat.com>
	<61930391.1031313088@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gh@us.ibm.com, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin.Bligh@us.ibm.com
In-Reply-To: <61930391.1031313088@[10.10.2.3]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
   Date: Fri, 06 Sep 2002 11:51:29 -0700
   
   I see no reason why turning on NAPI should make the Apache setup
   we have perform worse ... quite the opposite. Yes, we could use
   Tux, yes we'd get better results. But that's not the point ;-)

Of course.

I just don't want propaganda being spread that using Tux means you
lose any sort of web server functionality whatsoever.
