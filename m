From: Michael Buesch <mb@bu3sch.de>
Subject: Re: pull request: wireless-2.6 'upstream' 2008-01-22
Date: Wed, 23 Jan 2008 12:30:07 +0100
Message-ID: <200801231230.07734.mb@bu3sch.de>
References: <20080123014521.GG3206@tuxdriver.com> <20080123121551.4586e706@morte>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:34310 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbYAWLbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 06:31:31 -0500
In-Reply-To: <20080123121551.4586e706@morte>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 January 2008 12:15:51 Stefano Brivio wrote:
> On Tue, 22 Jan 2008 20:45:21 -0500
> "John W. Linville" <linville@tuxdriver.com> wrote:
> 
> >       b43legacy: Remove the PHY spinlock
> 
> I hope you tested this. I still haven't been able to (I received the
> needed hardware yesterday), and Michael said that the patch has been
> compile-tested only.

John, if we use subject lines such as:

[PATCH RFT] foobar: bizbaz

That means the patch is _not_ submitted for inclusion, yet.
The RFT means Request-For-Testing. Ususally, if I send out such
patches, they are completely untested. I usually compiletest them,
but that's it.
But in future I can also put a comment into the mailbody that
explains why to not apply it, yet.

For this particular patch, please leave it in now. I'm pretty
sure it is correct. So actual testing will be done upstream now. ;)

-- 
Greetings Michael.
