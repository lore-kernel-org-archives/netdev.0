From: "David S. Miller" <davem@davemloft.net>
Subject: Re: net patches
Date: Tue, 4 Jan 2005 22:31:04 -0800
Message-ID: <20050104223104.2ec87f5b.davem@davemloft.net>
References: <20050104215913.274e6567.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050104215913.274e6567.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Jan 2005 21:59:13 -0800
Andrew Morton <akpm@osdl.org> wrote:

> I'll unload some accumulated net patches.  I can't say that I've looked at
> them very closely.

I'll be quiet for the next few days as I try to discover why
sparc64 now explodes after the past week of changes.  I'm
heavily suspecting the 4-level page table stuff.  wli kept
saying that he was having trouble getting his sparc boxes
working with the -mm tree over the past month and that's about
how long the 4-level page table stuff has been in there.

What's odd is that Andi's original 4-level page table patch
he gave to me worked just fine on sparc64, but it's been
changed a lot.
