From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ibmtr - get rid of MOD_INC/DEC
Date: Sat, 16 Aug 2003 07:38:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030816073804.2464c5e2.davem@redhat.com>
References: <20030813174658.2c5125af.shemminger@osdl.org>
	<20030814205747.5fcd83d0.davem@redhat.com>
	<3F3CE05D.5080306@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mikep@linuxtr.net, linux-tr@linuxtr.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F3CE05D.5080306@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Aug 2003 09:30:05 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> David S. Miller wrote:
> > Can't we lose the MODULE ifdefs too?
> 
> Doubtful for ibmtr, which requires some of them for ibmtr_cs (which 
> #includes it).

Indeed.

Patch applied, thanks Stephen.
