From: "David S. Miller" <davem@redhat.com>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Mon, 30 Sep 2002 03:32:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020930.033230.90062153.davem@redhat.com>
References: <200209261309.RAA17837@sex.inr.ac.ru>
	<20020926.134608.31605412.davem@redhat.com>
	<20020930095909.GA8063@toey.sourcefrog.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, ak@muc.de, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mbp@samba.org
In-Reply-To: <20020930095909.GA8063@toey.sourcefrog.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Martin Pool <mbp@samba.org>
   Date: Mon, 30 Sep 2002 19:59:10 +1000

   On 26 Sep 2002, "David S. Miller" <davem@redhat.com> wrote:
   >    Dave, do you not remember this?
   
   So where does this leave us?  

Someone has to agree that the patch should go in.

Problem is, at least two of us do not run 2.2.x at all on any
of our systems (actually all of my currently powered-on machines
aren't even supported in 2.2.x) which makes it hard for
us to test this ourselves.
