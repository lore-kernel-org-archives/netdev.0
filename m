From: Pavel Roskin <proski@gnu.org>
Subject: Re: linux/802_11.h header
Date: Tue, 30 Mar 2004 18:23:46 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403301820001.8684@marabou.research.att.com>
References: <Pine.LNX.4.58.0403301514080.7498@marabou.research.att.com>
 <20040330215128.GA13891@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040330215128.GA13891@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Mar 2004, Jean Tourrilhes wrote:

> > Does anybody know who wrote 802_11.h, whether it's deprecated, and if not,
> > why it's not used?
>
> 	Why don't you ask Simon directly ?

Because my question is not why atmel_cs uses a header it doesn't need
(the answer would be likely "oops" or "just in case").

My question is why we have two headers for the same purpose in the kernel
and what are we going to do with the header that is not used.

-- 
Regards,
Pavel Roskin
