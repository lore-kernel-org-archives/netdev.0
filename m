From: Andi Kleen <ak@suse.de>
Subject: Re: question about linux tcp request queue handling
Date: Tue, 8 Jul 2003 01:52:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708015201.4a5ad7e6.ak@suse.de>
References: <3F08858E.8000907@us.ibm.com.suse.lists.linux.kernel>
	<001a01c3441c$6fe111a0$6801a8c0@oemcomputer.suse.lists.linux.kernel>
	<3F08B7E2.7040208@us.ibm.com.suse.lists.linux.kernel>
	<000d01c3444f$e6439600$6801a8c0@oemcomputer.suse.lists.linux.kernel>
	<3F090A4F.10004@us.ibm.com.suse.lists.linux.kernel>
	<001401c344df$ccbc63c0$6801a8c0@oemcomputer.suse.lists.linux.kernel>
	<p73fzliqa91.fsf@oldwotan.suse.de>
	<m3brw6rn3m.fsf@varsoon.wireboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: palbrecht@qwest.net, niv@us.ibm.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Doug McNaught <doug@mcnaught.org>
In-Reply-To: <m3brw6rn3m.fsf@varsoon.wireboard.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 07 Jul 2003 18:25:17 -0400
Doug McNaught <doug@mcnaught.org> wrote:

> And furthermore, IIRC, the current Linux networking code is not
> Berkeley-derived, though an earlier version was.

The linux network stack was never BSD derived in any way.

[there are two header files that came from net2, but they do not 
contain any code]

-Andi
