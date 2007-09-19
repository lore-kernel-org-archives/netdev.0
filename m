From: Andi Kleen <andi@firstfloor.org>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 21:40:50 +0200
Message-ID: <20070919194050.GE18707@one.firstfloor.org>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de> <46F15305.2030507@redhat.com> <20070919172653.GB18045@one.firstfloor.org> <46F1608E.7060908@redhat.com> <20070919175700.GC18045@one.firstfloor.org> <46F16418.3070706@redhat.com> <20070919183004.GA18707@one.firstfloor.org> <46F16CC1.9090302@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50120 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbXISTkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 15:40:52 -0400
Content-Disposition: inline
In-Reply-To: <46F16CC1.9090302@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It has hung-on in various places (stacks) as an "accepted" broadcast IP 
> in the receive path, but not the send path for quite possibly decades now.

Well it is valid in Linux for sending.  And who knows who relies on it.

-Andi

