From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 0/3] path mtu hardening patches
Date: Mon, 13 Jan 2014 23:15:04 +0100
Message-ID: <20140113221504.GM6586@order.stressinduktion.org>
References: <1389258077-23282-1-git-send-email-hannes@stressinduktion.org> <20140113.112504.922587457597727366.davem@davemloft.net> <CABrhC0n2AgHNQg-2nQk-sx1=k2=TvmGa+2seqoNT=XyDdz59yg@mail.gmail.com> <20140113204253.GI6586@order.stressinduktion.org> <CABrhC0=9ff8aLG4y4gxiGrGBBHvdcWD2pCC3wyLTveKHRySg4A@mail.gmail.com> <20140113212808.GJ6586@order.stressinduktion.org> <CABrhC0=CfPxB7rNrA0ukfZyNLuTNSBB2srohr-Yt2b4k6oHWxg@mail.gmail.com> <20140113220356.GL6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: John Heffner <johnwheffner@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	steffen.klassert@secunet.com, fweimer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33681 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbaAMWPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:15:05 -0500
Content-Disposition: inline
In-Reply-To: <20140113220356.GL6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 11:03:56PM +0100, Hannes Frederic Sowa wrote:
> I really don't like to depend on firewalling to do that. Especially on
> big routers one can use the routing table to protect interfaces for
> management and thus don't need to introduce stateful firewalling to
> realize a secure router setup which could cause performance degradation,
> especially with lots of small and shortlived flows (e.g. UDP/DNS).

This may get better if maybe some work is put into bringing this patch
forward: http://comments.gmane.org/gmane.linux.network/268758

Greetings,

  Hannes
