From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] remove DMA_nBIT_MASK macro
Date: Thu, 07 May 2009 11:03:29 +0200
Message-ID: <4A02A3E1.90706@gmail.com>
References: <20090507141114M.fujita.tomonori@lab.ntt.co.jp> <20090506223452.65e545d8.akpm@linux-foundation.org> <4A029BE1.4090309@cn.fujitsu.com> <4A029FD1.1050007@gmail.com> <4A02A2D8.4090209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:56721 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbZEGJDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 05:03:34 -0400
In-Reply-To: <4A02A2D8.4090209@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2009 10:59 AM, Yang Hongyang wrote:
> Jiri Slaby wrote:
>> Something like an irq flags deprecation in the past:
>> http://lwn.net/Articles/229673/
>> ?
> 
> good catch,but this need to be modified (add one line is enough)to cause their use to
> cause __deprecated warnings.

I'm lost, that inline does it, right?
