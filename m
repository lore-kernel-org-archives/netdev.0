From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: [PATCH] pcnet_cs: add new id
Date: Sun, 5 Jul 2009 17:34:04 +0900
Message-ID: <20090705173404.2e007d9b.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090628090939.c04680a3.ken_kawasaki@spring.nifty.jp>
	<20090630.071955.193724693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg501.nifty.com ([202.248.238.81]:59149 "EHLO
	userg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755074AbZGEIeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 04:34:21 -0400
In-Reply-To: <20090630.071955.193724693.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Jun 2009 07:19:55 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> > (3) change default setting of use_shmem to 0.
> >     because shared memory does not work on some PC.

Sorry, I cancel the use_shmem patch. (for re-test).


Ken.
