From: "David S. Miller" <davem@redhat.com>
Subject: Re: Flow cache flush oops
Date: Wed, 18 Jun 2003 12:23:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618.122311.118621111.davem@redhat.com>
References: <1055964154.1818.59.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1055964154.1818.59.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Tom Lendacky <toml@us.ibm.com>
   Date: 18 Jun 2003 14:22:33 -0500

   I consistently receive the following oops on 2.5.72 on an SMP machine
   after flushing some IPSec policy's and sa's that I had established and
   sent data through.

I've forwarded your report to Herbert, who worked on this stuff.
He should be able to figure it out.
