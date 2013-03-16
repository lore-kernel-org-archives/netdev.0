From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: igb_poll - device driver failed to check map error
Date: Sat, 16 Mar 2013 10:27:29 +0100
Message-ID: <4445053.7p3fLHaGul@cpaasch-mac>
References: <7974689.msj0QTRKPV@cpaasch-mac> <1899985.NhtD8IVCbT@cpaasch-mac> <804857E1F29AAC47BF68C404FC60A1844D9E2F00@ORSMSX103.amr.corp.intel.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:40103 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948Ab3CPJ1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 05:27:36 -0400
Received: by mail-ea0-f175.google.com with SMTP id o10so1828116eaj.6
        for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 02:27:35 -0700 (PDT)
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1844D9E2F00@ORSMSX103.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 15 March 2013 16:03:47 Allan, Bruce W wrote:
> You are correct re. the missing calls to dma_mapping_error and I have that
> on my to-do list for e1000e, but if you have patches already feel free to
> send them along (please cc the Intel wired ethernet list
> e1000-devel@lists.sourceforge.net).

I will send them soon, after some basic tests.

Cheers,
Christoph

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--
