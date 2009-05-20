From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Wed, 20 May 2009 10:36:59 +0400
Message-ID: <20090520063659.GA10062@night.netis.ru>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com> <20090519162330.GC28034@hmsreliant.think-freely.org> <20090519171703.GA2749@ami.dom.local> <20090519174504.GD28034@hmsreliant.think-freely.org> <20090519180505.GB2981@ami.dom.local> <20090519181607.GE28034@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from night.yars.free.net ([193.233.48.54]:62518 "EHLO
	night.yars.free.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbZETGiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 02:38:11 -0400
Content-Disposition: inline
In-Reply-To: <20090519181607.GE28034@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 02:16:07PM -0400, Neil Horman wrote:
> Alexander, can you point out
> the location of the move-to-front heruistic that you mention in your analysis?

It's near /* Put it first */ comment (if I read the code correctly).

-- 
   Alexander..
