From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: net-2.6 being rebased...
Date: Tue, 3 Jun 2008 14:27:34 -0700
Message-ID: <396556a20806031427j4e8c793fl4be394a5c145325e@mail.gmail.com>
References: <20080603.142407.08652094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linville@tuxdriver.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:34783 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbYFCV1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:27:39 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1778298rvb.1
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 14:27:39 -0700 (PDT)
In-Reply-To: <20080603.142407.08652094.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 3, 2008 at 2:24 PM, David Miller <davem@davemloft.net> wrote:
> Because of the bugs in Adam's MD5/SACK fix I need to rebase
> the tree to get rid of it.  Adam, please post a complete
> new patch once you've fixed that SACK option adding problem.
> Thanks.

I'm just finishing up a proposed fix if you want to hold off.


AGL
