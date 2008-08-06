From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: hash_list and rcu locking question
Date: Thu, 7 Aug 2008 00:54:21 +0400
Message-ID: <20080806205421.GB6277@2ka.mipt.ru>
References: <379e30200808060856h112ec1d6x2b7ec6497a32de09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Tobias Koeck <tobias.koeck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:33734 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757118AbYHFUyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 16:54:18 -0400
Content-Disposition: inline
In-Reply-To: <379e30200808060856h112ec1d6x2b7ec6497a32de09@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tobias.

On Wed, Aug 06, 2008 at 05:56:43PM +0200, Tobias Koeck (tobias.koeck@gmail.com) wrote:
> Are the hash_list rcu functions avoiding all locking problems (even
> the one with only one CPU)?

What is hash list? hlist? Or list in a hash bucket?
Does include/linux/rculist.h contain needed bits?

> Are there some abstract examples for the use of the hash_{head,list} structures?

Sorry, my kernel source tree does not know what is 'hash_head'.
What data structure exactly do you mean?

-- 
	Evgeniy Polyakov
