From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 patch] IPV6 addrconf.c: remove unused functions and
 variables
Date: Sat, 13 Mar 2004 22:52:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313225253.00b55b4d.davem@redhat.com>
References: <20040313193959.GB14833@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roque@di.fc.ul.pt, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>
In-Reply-To: <20040313193959.GB14833@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 13 Mar 2004 20:39:59 +0100
Adrian Bunk <bunk@fs.tum.de> wrote:

> The patch
> 
>   [IPV6]: Do not report {multi,any}cast in inet6_dump_ifaddr().
> 
> in Linus' tree removed the only uses of two functions and two variables
> and therefore caused the following compile warnings:

I know, I have this pending in my tree already.
