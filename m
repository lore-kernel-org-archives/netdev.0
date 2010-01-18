From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Mon, 18 Jan 2010 23:40:07 +0100
Message-ID: <20100118224007.GA3498@del.dom.local>
References: <20100117230531.GC3161@del.dom.local>
 <4B539A0A.2000504@majjas.com>
 <20100118073018.GA6270@ff.dom.local>
 <4B548C6B.10607@majjas.com>
 <20100118204658.GC3157@del.dom.local>
 <4B54CB0D.5070604@majjas.com>
 <20100118212516.GE3157@del.dom.local>
 <4B54D50C.90608@majjas.com>
 <20100118220814.GG3157@del.dom.local>
 <4B54DFE7.4060802@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755700Ab0ARWkT@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B54DFE7.4060802@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 18, 2010 at 05:25:43PM -0500, Michael Breuer wrote:
> On 1/18/2010 5:08 PM, Jarek Poplawski wrote:
> >Could you remind us if the problem is always with this first device?
> >Btw, I wonder if you could test it skipping the (HP?) switch?
> >
> >Jarek P.
> No - can be any device connected via the wifi router - wired or wireless.

Anyway, if it can't be repeated with this Win7 box or even the router
getting dhcp itself, then this router's interaction seems most
suspected.

Jarek P.
