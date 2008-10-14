From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Distributed storage release.
Date: Tue, 14 Oct 2008 20:12:56 +0400
Message-ID: <20081014161256.GA22286@2ka.mipt.ru>
References: <20081006160034.GA611@2ka.mipt.ru> <20081012192419.fd8394c9.akpm@linux-foundation.org> <20081013133850.GA13565@2ka.mipt.ru> <20081014155143.GM2009@webber.adilger.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andreas Dilger <adilger@sun.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081014155143.GM2009@webber.adilger.int>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andreas.

On Tue, Oct 14, 2008 at 09:51:43AM -0600, Andreas Dilger (adilger@sun.com) wrote:
> While it is true that one coding style vs. another could be argued for
> a long time - the right answer is that the _right_ coding style for code
> added to the Linux kernel is Linus' CodingStyle document.
> 
> Whether you think the braces here or there look better - consistency
> with other code in the same project is very important, and any changes
> you get to your code will come in the Linus CodingStyle and this will
> result in code that is a mix between your personal style and the official
> style and it will be a mess...

Like Scsi_Host and include/scsi/scsi_host.h? My favourite coding style
standards! It has the same space issues I have, but my code does not use
capital letters :)

I always wondered... I submit almost 5 thousands line of code and I'm
blamed that I do not have or have too many spaces in several dozens of
lines. Should I get it as kernel hackers can not say anything bad about
project except amount of spaces?

Btw, ext4 headers have the same issues with long lines as DST has. I'm
pretty sure no one would notice that (as long as in DST) without
checkpatch, which basically means that people do not care about the
code.

-- 
	Evgeniy Polyakov
