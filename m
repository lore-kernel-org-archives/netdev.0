From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.73] update teql scheduler to dynamic net device
Date: Mon, 23 Jun 2003 13:13:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030623.131343.88494977.davem@redhat.com>
References: <20030623115755.754205ab.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030623115755.754205ab.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 23 Jun 2003 11:57:55 -0700
   
   Change teql scheduler to:
   	- dynamically allocate and free the network device.
   	  previously, used static network device.
   	- support multiple equalizers (default one) via module parameter (max_equalizers)
   	  previously, limited to one.

Applied, thanks Stephen.
