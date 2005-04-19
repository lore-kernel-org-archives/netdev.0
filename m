From: Rick Jones <rick.jones2@hp.com>
Subject: Re: NAPI and CPU utilization [was: NAPI, e100, and system performance
 problem]
Date: Tue, 19 Apr 2005 13:52:18 -0700
Message-ID: <42656F82.3030600@hp.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>	<Pine.LNX.4.61.0504180943290.15052@linux.site>	<1113855967.7436.39.camel@localhost.localdomain>	<20050419055535.GA12211@sgi.com>	<20050419113657.7290d26e.davem@davemloft.net> <Pine.LNX.4.61.0504191210040.15052@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Greg Banks <gnb@sgi.com>,
        hadi@cyberus.ca, jesse.brandeburg@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504191210040.15052@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

One issue/caveat/whatever on those coalescing parms and such.  Watch-out for 
their effect on request/response performance on stuff like netperf TCP_RR.

rick jones
