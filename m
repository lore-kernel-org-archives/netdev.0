From: "David S. Miller" <davem@redhat.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 03 Jun 2003 21:47:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.214730.08347437.davem@redhat.com>
References: <3EDD52F5.8090706@us.ibm.com>
	<20030603.202320.59680883.davem@redhat.com>
	<16093.30507.661714.676184@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, kuznet@ms2.inr.ac.ru, jmorris@intercode.com.au,
   gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org,
   linux-ia64@linuxia64.org, netdev@oss.sgi.com, akpm@digeo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com, davidm@napali.hpl.hp.com
In-Reply-To: <16093.30507.661714.676184@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: David Mosberger <davidm@napali.hpl.hp.com>
   Date: Tue, 3 Jun 2003 21:35:55 -0700

   Is this where I get to plug httperf?  It triggered the bug reliably in
   less than 10 secs. ;-)

distcc was a reliable test case too...
