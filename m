From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Mon, 28 Feb 2005 02:28:28 +0900 (JST)
Message-ID: <20050228.022828.120983354.yoshfuji@linux-ipv6.org>
References: <200502270928.44402.Info@Quantum-Sci.com>
	<20050228.011038.129063054.yoshfuji@linux-ipv6.org>
	<200502271029.02532.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
To: Info@Quantum-Sci.com
In-Reply-To: <200502271029.02532.Info@Quantum-Sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200502271029.02532.Info@Quantum-Sci.com> (at Sun, 27 Feb 2005 10:29:02 -0600), Quantum Scientific <Info@Quantum-Sci.com> says:

> And I have looked at every single file in the Split directory, and there are 
> absolutely no .diff files.  .diff files are how patch files are identified in 
> *nix, of course.  I thought, maybe I should copy the kernel files into my 
> kernel tree by hand, for building.  But this doesn't make sense because the 
> only file under usagi-split/kernel/usagi/net/ipv6 is utils.c .  This is not 
> an IPV6 stack, nor ip6tables.  I see lots of apps, which likely have the 
> USAGI improvements, but no kernel stack, patch, ipv6filters, etc.  And no 
> mention of patching a non-USAGI kernel.  Split 20050214 appears to be 
> utilities only.

Don't you find diff files?! e.g:
  ftp://ftp.linux-ipv6.org/pub/usagi/snap/split/usagi-linux26-s20050214-2.6.11-rc3.diff.bz2
is patch against linux-2.6.11-rc3.

--yoshfuji
