From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: Scaling Max IP address limitation
Date: Mon, 25 Jun 2007 11:30:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0706251130320.11964@fbirervta.pbzchgretzou.qr>
References: <467EA7C1.4080006@rossove.com>  <20070624110236.fa36b2f9.akpm@linux-foundation.org>
  <7e63f56c0706241259u6e123ed6yc02b76f0260adaa5@mail.gmail.com>
 <467F063A.2030805@rossove.com> <7e63f56c0706250147w508d3aeay5f7aaca8215953c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: djones@rossove.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Robert Iakobashvili <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:14529 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbXFYJa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 05:30:58 -0400
In-Reply-To: <7e63f56c0706250147w508d3aeay5f7aaca8215953c8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 25 2007 11:47, Robert Iakobashvili wrote:
>
> I am getting after initial successes some errors:
> "rtnl_talk(): RTNETLINK answers: Cannot allocate memory"
> and
> #ip addr | wc-l is 8194.

I'd be surprised if it was 4096 on x86 and 8192 on x86_64...


	Jan
-- 
