From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: HostAP:  alive or dead?
Date: Fri, 28 May 2004 18:49:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529014951.GE7535@jm.kir.nu>
References: <40B62FD3.8040601@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40B62FD3.8040601@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 27, 2004 at 02:13:39PM -0400, Jeff Garzik wrote:

> I've been wanting to merge it, and starting working on the generic 
> wireless layer, for a while now.

Yes, it is very much alive. However.. I'm sorry I haven't been able to
get enough time to work on finishing the cleanup I planned for 2.6
submission. Another IEEE 802.11 meeting and WPA2 testing took a lot of
time during last weeks. Anyway, it looks like I might not need to travel
anywhere during the following few weeks (well, at least I'm hoping ;-),
so I could try to concentrate on this now.

I'll try to get an initial submission for wireless-2.6 done over the
weekend so that something becomes available for reviewing. What would
be the best format for this? Would it be ok to send a patch against the
current linus-2.5 tree for the couple of modified files (Kconfig,
Makefile) and rest of the files in a separate tarball since they do not
exist in the current tree and are relatively large?

-- 
Jouni Malinen                                            PGP id EFC895FA
