From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: fib_hash.c:fn_hash()
Date: Thu, 24 Jun 2004 11:39:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40DAF5AB.60108@pobox.com>
References: <20040624010938.55f90500.akpm@osdl.org> <20040624103905.GB16727@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040624103905.GB16727@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> BTW if we don't want to supply these functions we should change
> the kernel to compile with -ffreestanding. But so far at least 
> the common ports are good enough at that now that it isn't needed.

Agreed...
