From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] libertas: name the network device wlan%d
Date: Thu, 13 Aug 2009 12:28:47 -0500
Message-ID: <1250184527.5896.32.camel@localhost.localdomain>
References: <1250000012-25673-1-git-send-email-daniel@caiaq.de>
	 <20090811143401.GD2684@tuxdriver.com>
	 <1250094662.31650.24.camel@localhost.localdomain>
	 <818423da0908122048p1fa69a2bnd570071f11336089@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roel Kluin <roel.kluin@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Daniel Mack <daniel@caiaq.de>, libertas-dev@lists.infradead.org
To: Daniel Drake <dsd@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53856 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755167AbZHMR3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 13:29:19 -0400
In-Reply-To: <818423da0908122048p1fa69a2bnd570071f11336089@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 09:33 +0545, Daniel Drake wrote:
> 2009/8/12 Dan Williams <dcbw@redhat.com>:
> > Daniel, is it a problem for you guys if the libertas wifi interface name
> > went from 'eth' -> 'wlan' ?  Mesh name would be unchanged.
> 
> I can't think of any problems.

In that case:

Acked-by: Dan Williams <dcbw@redhat.com>

