From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/2] net: sch_generic: react upon IFF_NO_QUEUE flag
Date: Mon, 17 Aug 2015 08:53:17 +0200
Message-ID: <20150817085317.45c32269@redhat.com>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
	<1439485268-20953-2-git-send-email-phil@nwl.cc>
	<1439485268-20953-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbbHQGxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 02:53:19 -0400
In-Reply-To: <1439485268-20953-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Aug 2015 19:01:07 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Handle IFF_NO_QUEUE as alternative to tx_queue_len being zero.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
