From: Andrew Morton <akpm@osdl.org>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k31 for upstream
 inclusion
Date: Thu, 22 Jun 2006 14:22:17 -0700
Message-ID: <20060622142217.0abfe030.akpm@osdl.org>
References: <0BB3E5E7462EEA4295BC02D49691DC07176862@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Linux-Driver@qlogic.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27289 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932601AbWFVVTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 17:19:10 -0400
To: "Ron Mercer" <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC07176862@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Ron Mercer" <ron.mercer@qlogic.com> wrote:
>
> Thanks for your feedback.  I've fixed everything you mentioned with the
> exception of the code below.  I need to swap every other byte pair of my
> nvram mac address for big endian systems.  Everything else I tried was
> more messy.  Did you have anything specific in mind?

Nope, it was more a question for the other netdev developers.  If nobody
can point at a library function or something then fine, leave it as-is.
