From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Established connections hash function II
Date: 28 Mar 2007 16:17:01 +0200
Message-ID: <p73tzw5312a.fsf_-_@bingen.suse.de>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
	<p73lkhi6aj7.fsf@bingen.suse.de>
	<EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON>
	<200703281129.43783.ak@suse.de> <20070328104505.GA18748@2ka.mipt.ru>
	<p73y7lh316u.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, nikb@webmaster.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47780 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbXC1NS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 09:18:27 -0400
In-Reply-To: <p73y7lh316u.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <andi@firstfloor.org> writes:

> The only truly variable thing is the 
> boot time, which can be guessed 

Actually you don't need to guess it. It's in any TCP timestamp.

-Andi
