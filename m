From: Dan Williams <dcbw@redhat.com>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 22:02:18 -0500
Message-ID: <1166670138.23168.7.camel@localhost.localdomain>
References: <20061219185223.GA13256@srcf.ucam.org>
	 <1166638371.2798.26.camel@localhost.localdomain>
	 <20061221011526.GB32625@srcf.ucam.org>
	 <200612202057.09545.flamingice@sourmilk.net>
	 <20061221022053.GB723@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>, Jiri Benc <jbenc@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161164AbWLUDAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 22:00:17 -0500
To: Matthew Garrett <mjg59@srcf.ucam.org>
In-Reply-To: <20061221022053.GB723@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-21 at 02:20 +0000, Matthew Garrett wrote:
> On Wed, Dec 20, 2006 at 08:57:05PM -0500, Michael Wu wrote:
> 
> (allowing scanning while the interface is down)
> 
> > No, it's absolutely a bug. It just so happens that some drivers incorrectly 
> > allowed it.
> 
> Ok. Would it be reasonable to add warnings to any devices that allow it?

Quite reasonable.

Dan


