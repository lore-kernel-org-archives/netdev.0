From: "J.A. Magallon" <jamagallon@able.es>
Subject: Re: 2.6.1-mm4
Date: Sun, 18 Jan 2004 09:11:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040118081128.GA3153@werewolf.able.es>
References: <20040115225948.6b994a48.akpm@osdl.org> <20040118001217.GE3125@werewolf.able.es> <20040117215535.0e4674b8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040117215535.0e4674b8.akpm@osdl.org> (from akpm@osdl.org on Sun, Jan 18, 2004 at 06:55:35 +0100)
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On 01.18, Andrew Morton wrote:
> "J.A. Magallon" <jamagallon@able.es> wrote:
> >
> > On 01.16, Andrew Morton wrote:
> >  > 
> >  > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm4/
> >  > 
> >  > 
> > 
> >  Net driver problem:
> > 
> >  werewolf:/etc# modprobe --verbose 3c59x
> >  insmod /lib/modules/2.6.1-jam4/kernel/drivers/net/3c59x.ko 
> >  FATAL: Error inserting 3c59x (/lib/modules/2.6.1-jam4/kernel/drivers/net/3c59x.ko): Invalid argument
> 
> hmm, cute.
> 

Yes.
It worked. 
I thought of this, but why this and not the other parameters ? Compiler bug ?

Witches...

-- 
J.A. Magallon <jamagallon()able!es>     \                 Software is like sex:
werewolf!able!es                         \           It's better when it's free
Mandrake Linux release 10.0 (Cooker) for i586
Linux 2.6.1-jam4 (gcc 3.3.2 (Mandrake Linux 10.0 3.3.2-4mdk))
