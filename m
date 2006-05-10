From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/6] myri10ge - First half of the driver
Date: Wed, 10 May 2006 15:01:12 -0700
Message-ID: <20060510150112.46a732d4@localhost.localdomain>
References: <446259A0.8050504@myri.com>
	<Pine.GSO.4.44.0605101438410.498-100000@adel.myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>, <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15490 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932305AbWEJWBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 18:01:19 -0400
To: Brice Goglin <bgoglin@myri.com>
In-Reply-To: <Pine.GSO.4.44.0605101438410.498-100000@adel.myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 May 2006 14:40:22 -0700 (PDT)
Brice Goglin <bgoglin@myri.com> wrote:

> [PATCH 4/6] myri10ge - First half of the driver
> 
> The first half of the myri10ge driver core.
> 

Splitting it in half, might help email restrictions, but it kills
future users of 'git bisect' who expect to have every kernel buildable.
