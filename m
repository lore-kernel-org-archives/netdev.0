From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] snmp6 stats as %lu
Date: Thu, 03 Apr 2003 08:11:01 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030403.081101.64240524.davem@redhat.com>
References: <20030402122755.5dc3f022.rddunlap@osdl.org>
	<20030403.044822.00469453.davem@redhat.com>
	<20030403080244.6bb772e3.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rddunlap@osdl.org
In-Reply-To: <20030403080244.6bb772e3.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Randy.Dunlap" <rddunlap@osdl.org>
   Date: Thu, 3 Apr 2003 08:02:44 +0000

   On Thu, 03 Apr 2003 04:48:22 -0800 (PST) "David S. Miller" <davem@redhat.com> wrote:
   
   | Looks like an oversight to me, both should use the unsigned format.
   
   Here's the patch, on top of the seq_file conversion.

Applied, thanks Randy.
