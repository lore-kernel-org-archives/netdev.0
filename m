From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] (3/3) netem: adjust parent qlen when duplicating
Date: Tue, 3 May 2005 16:59:37 -0700
Message-ID: <20050503165937.0c6cac6d.davem@davemloft.net>
References: <20050503162550.30acf31a@dxpl.pdx.osdl.net>
	<42780AC1.8040409@trash.net>
	<20050503163025.38bb9682.davem@davemloft.net>
	<42780DB2.2090201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42780DB2.2090201@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 04 May 2005 01:48:02 +0200
Patrick McHardy <kaber@trash.net> wrote:

> That's what I already suggested, it should be pretty simple to do
> so. I'll send a patch once your tree appears on kernel.org.

Thanks.

> BTW, are you pushing it regulary or just for Linus to merge?

I tend to process a batch of patches, then push the kernel.org,
then to Linus.

I just pushed my tree to:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git/

and you poke it on the web via:

http://www.kernel.org/git/

My net-2.6 tree is in the list there at:

http://www.kernel.org/git/gitweb.cgi?p=linux%2Fkernel%2Fgit%2Fdavem%2Fnet-2.6.git;a=log

as soon as Marcelo has his GIT tree going for 2.4.x, I'll put Sparc and Net
trees up for that as well.
