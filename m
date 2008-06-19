From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/4] e1000: various bug fixes for older hardware
Date: Thu, 19 Jun 2008 15:33:46 -0700
Message-ID: <9929d2390806191533p70caab37ub3084562ec7fda91@mail.gmail.com>
References: <20080619211827.GB22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: "Andy Gospodarek" <andy@greyhouse.net>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:11915 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbYFSWdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 18:33:47 -0400
Received: by wa-out-1112.google.com with SMTP id j37so714588waf.23
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 15:33:46 -0700 (PDT)
In-Reply-To: <20080619211827.GB22981@gospo.rdu.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 19, 2008 at 2:18 PM, Andy Gospodarek <andy@greyhouse.net> wrote:
>
> These are 4 separate e1000 fixes that I've been collecting for a bit.
> Of course most of this hardware is pretty old, but there are still a ton
> of people using it, so it's good to get these fixes in place.
>
> They are not dependent on each other, so feel free to comment on them
> individually if you like.
>
> None of these currently appear in the e1000 sourceforge driver, so they
> will need to be added there by someone if they want them.
>

Ack
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


-- 
Cheers,
Jeff
