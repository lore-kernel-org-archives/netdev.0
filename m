From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH 1 2.6.7-rc3-bk6] pcnet32: discard oversize rx packets
Date: Tue, 15 Jun 2004 12:06:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406151906.i5FJ6KK20782@localhost.localdomain>
References: <20040615115829.46a6a674.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rddunlap@osdl.org (Randy.Dunlap)
In-Reply-To: <20040615115829.46a6a674.rddunlap@osdl.org> from "Randy.Dunlap" at Jun 15, 2004 11:58:29 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My preceeding two patches should have said:

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

Do I need to resubmit them?


> | This patch will discard received frames that are larger than one buffer.
> | This has been tested on ia32 and ppc64 systems.
> | 
> | Please also apply to 2.4.7 (with offset of -3), tested ia32.
> | 
> | Signed-off by: brazilnut@us.ibm.com
> 
> Don-
> 
> The requested format is:
> 
> Signed-off-by: your name <email address>
> 
> --
> ~Randy
-- 
Don Fry
brazilnut@us.ibm.com
