From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Established connections hash function
Date: Tue, 27 Mar 2007 23:29:33 -0700 (PDT)
Message-ID: <20070327.232933.71090935.davem@davemloft.net>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
	<p73lkhi6aj7.fsf@bingen.suse.de>
	<EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ak@suse.de
To: nikb@webmaster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58402
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933620AbXC1G3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 02:29:34 -0400
In-Reply-To: <EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Date: Tue, 27 Mar 2007 22:01:38 -0700

>     What this boils down to is, yes, we can keep patching our own kernels to 
> use tagged jenkins hashing if this affects us, waiting for something better 
> to come along.

You don't have to patch, I put jenkins into the tree and it will
hit 2.6.22, we don't need to even discuss this any more and you
can safely ignore Andi.
