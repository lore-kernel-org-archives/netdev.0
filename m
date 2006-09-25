From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: bcm43xx driver unstable behaviour (and linux wireless is junk
	btw)
Date: Mon, 25 Sep 2006 12:00:47 +0200
Message-ID: <1159178447.4509.17.camel@ux156>
References: <1159065798.5924.8.camel@localhost.localdomain>
	 <4515FF5D.4080602@gentoo.org>
	 <1159078683.5924.16.camel@localhost.localdomain>
	 <1159174960.4509.13.camel@ux156>
	 <1159178281.13140.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43163 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750917AbWIYKAG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 06:00:06 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1159178281.13140.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-25 at 19:58 +1000, Benjamin Herrenschmidt wrote:

> Doh ! Scary... locking is hard ... if the stuff was written without
> locking in mind in the first place, it might end up being a nightmare...

Yeah, I've actually suggested "rewriting" it from its own pieces :) But
Jiri says he understands it well enough now to not have to do that.

johannes
