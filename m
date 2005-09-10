From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.13-mm2
Date: Sat, 10 Sep 2005 16:56:59 -0700
Message-ID: <20050910165659.5eea90d0.akpm@osdl.org>
References: <20050908053042.6e05882f.akpm@osdl.org>
	<1126396015l.6300l.1l@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932397AbVIJX53@vger.kernel.org>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <1126396015l.6300l.1l@werewolf.able.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"J.A. Magallon" <jamagallon@able.es> wrote:
>
> 
> On 09.08, Andrew Morton wrote:
> > 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.13/2.6.13-mm2/
> > 
> > (kernel.org propagation is slow.  There's a temp copy at
> > http://www.zip.com.au/~akpm/linux/patches/stuff/2.6.13-mm2.bz2)
> > 
> > 
> 
> I can not ifup an interface while iptables is using it.
> Is this expected behaviour ?

Maybe it's expected, but breaking existing userspace is a serious issue.

> There is a possible bug (IMHO) in Mandrake initscripts, that start iptables
> before network interfaces, but this had always worked.
> 
> Any ideas ?

Please always cc netdev@vger.kernel.org on networking matters.
