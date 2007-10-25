From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v4] FEC - fast ethernet controller for mpc52xx
Date: Thu, 25 Oct 2007 18:46:19 -0400
Message-ID: <47211CBB.5080000@garzik.org>
References: <20071014075511.GC3000@nd47.coderock.org> <4713BA1C.2050604@pobox.com> <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com> <4717B09B.3060800@pobox.com> <20071019112700.GD27403@nd47.coderock.org> <47206209.8080109@pobox.com> <20071025185706.29496.qmail@farnsworth.org> <20071025194114.GH3369@nd47.coderock.org> <20071025202908.GA2102@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Domen Puncer <domen.puncer@telargo.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36603 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760504AbXJYWqW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 18:46:22 -0400
In-Reply-To: <20071025202908.GA2102@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> IMO, it's still a requirement that we call dma_unmap_single() for
> each call to dma_map_single().

Yep...


