From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.8-rc4-bk1 problem: unregister_netdevice: waiting for ppp0
 to become free. Usage count = 1
Date: Sat, 21 Aug 2004 22:25:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040821222503.51268490.davem@redhat.com>
References: <411BC284.6080807@vgertech.com>
	<20040813080334.GA13337@tentacle.sectorb.msk.ru>
	<411D2625.2070908@vgertech.com>
	<41280163.1050508@vgertech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, master@sectorb.msk.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nuno Silva <nuno.silva@vgertech.com>
In-Reply-To: <41280163.1050508@vgertech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 22 Aug 2004 03:13:55 +0100
Nuno Silva <nuno.silva@vgertech.com> wrote:

> This problem was introduced between 2.6.8-rc2-bk11 and 2.6.8-rc4-bk1 and 
> always happens. Right now I'm testing with 2.6.8.1 with a patch from Mr. 
> Miller -- "cacheline-align qdisc data in qdisc_create()" (attached).

Does that patch fix the problem?
