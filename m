From: "David S. Miller" <davem@redhat.com>
Subject: Re: [irda-users] [PATCH] Make VLSI FIR depend on X86
Date: Tue, 21 Oct 2003 01:13:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031021011320.3fa6888f.davem@redhat.com>
References: <20031021001241.390a16df.davem@redhat.com>
	<Pine.LNX.4.44.0310210929350.4246-100000@notebook.home.mdiehl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lists@mdiehl.de, noah@caltech.edu, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Diehl <lists@mdiehl.de>
In-Reply-To: <Pine.LNX.4.44.0310210929350.4246-100000@notebook.home.mdiehl.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Oct 2003 09:33:24 +0200 (CEST)
Martin Diehl <lists@mdiehl.de> wrote:

> One more question: Shouldn't the i386 implementation instead of being NOP 
> just call flush_write_buffers() - at least this is what the vlsi-private 
> implementation is doing at the moment?

That seems right, yes.
