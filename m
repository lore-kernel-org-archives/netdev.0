From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] iproute: Add magic cookie to route dump file
Date: Fri, 17 Aug 2012 13:49:43 -0700
Message-ID: <20120817134943.6f26a75e@nehalam.linuxnetplumber.net>
References: <50121F4D.8090606@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36255 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753192Ab2HQUt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 16:49:59 -0400
In-Reply-To: <50121F4D.8090606@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Jul 2012 08:55:41 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> In order to somehow verify that a blob contains route dump a
> 4-bytes magic is put at the head of the data and is checked
> on restore.
> 
> Magic digits are taken from Portland (OR) coordinates :) Is
> there any more reliable way of generating such?
> 
> Signed-of-by: Pavel Emelyanov <xemul@parallels.com>

I am planning on putting this in because there were no objections.
Any followup updates?
