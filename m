From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: linux-2.6.8.1 to linux-2.6.10: Kernel Patching Issues.
Date: Fri, 25 Feb 2005 11:47:23 -0500
Message-ID: <1109350044.9681.26.camel@krustophenia.net>
References: <Pine.LNX.4.10.10502251550520.26208-100000@mtfhpc.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
        jmorris@redhat.com, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
In-Reply-To: <Pine.LNX.4.10.10502251550520.26208-100000@mtfhpc.demon.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-02-25 at 16:40 +0000, Mark Fortescue wrote:
> Hi all,
> 
> I am not sure exactly where to send this email. A have chosen the
> ip4/ip6 networking as the issues are in this area of the kernel.
>  
> The kernel patch files patch-2.6.9 and patch-2.6.10 do not apear to be
> correct.

No, you're doing it wrong.  2.6.8.1 was a bugfix release.  The correct
patching order is 2.6.8 -> 2.6.9 -> 2.6.10. 

Lee
