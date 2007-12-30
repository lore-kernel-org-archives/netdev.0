From: Andi Kleen <andi@firstfloor.org>
Subject: Re: A question about hh_cache
Date: Sun, 30 Dec 2007 15:54:14 +0100
Message-ID: <p73abns1be1.fsf@bingen.suse.de>
References: <147a89290712300531m4a8845betd23ef71f6d944799@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Andy Johnson" <johnsonzjo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46846 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755299AbXL3OyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 09:54:17 -0500
In-Reply-To: <147a89290712300531m4a8845betd23ef71f6d944799@mail.gmail.com> (Andy Johnson's message of "Sun\, 30 Dec 2007 15\:31\:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Andy Johnson" <johnsonzjo@gmail.com> writes:

> Can anybody give an example when hh_cache of a neighbour instance is a
> list with more than
> one entry ?

When you're talking to the same host on a local ethernet with both native IPv4 
and native IPv6.

-Andi
