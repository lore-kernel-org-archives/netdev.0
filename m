From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Extend netlink error codes
Date: Mon, 13 Sep 2004 12:33:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913123308.00686fb2.davem@davemloft.net>
References: <20040910225158.GO20088@postel.suug.ch>
	<20040911155839.GN4431@wotan.suse.de>
	<20040911162433.GC21181@postel.suug.ch>
	<20040912163744.52f95367.davem@davemloft.net>
	<20040913062613.GA12185@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040913062613.GA12185@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 08:26:13 +0200
Andi Kleen <ak@suse.de> wrote:

> I actually don't think it will be a big issue for them.
> They already translate messages by mapping text to other
> text. The same thing could be done for kernel messages,
> by just marking them in the kernel somehow that they
> can be automatically extracted from the source and then 
> later mapping them to the translations in user space. 

I understand, but I'm specifically talking about this
"synchronization" issue.

Anyways, I think strings are fine.
