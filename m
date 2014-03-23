From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: ip6_append_data_mtu do not handle the mtu of the second fragment properly
Date: Sun, 23 Mar 2014 17:43:34 +0100
Message-ID: <20140323164334.GA19730@order.stressinduktion.org>
References: <1395031861-19564-1-git-send-email-lucien.xin@gmail.com> <20140317190534.GE12291@order.stressinduktion.org> <CADvbK_ciRc-1nCZcd-BzgLvLrbgCMcoHZ5gyMrkAcYunKSE36w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54493 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbaCWQng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 12:43:36 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_ciRc-1nCZcd-BzgLvLrbgCMcoHZ5gyMrkAcYunKSE36w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 23, 2014 at 04:33:19PM +0800, lucien xin wrote:
> >
> > Fixes: 75a493e60ac4bb ("ipv6: ip6_append_data_mtu did not care about pmtudisc and frag_size")
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >
> > Thank you!
> >
> hi, Hannes,
> 
> will the patch be added to -stable ?

Yes, it is already queued up, see:

http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

Greetings,

  Hannes
