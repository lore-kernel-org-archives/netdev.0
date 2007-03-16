From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] s2io: add PCI error recovery support
Date: Fri, 16 Mar 2007 15:58:52 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77015A97DD@nekter>
References: <20070316194941.GP5151@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Wen Xiong" <wenxiong@us.ibm.com>, <linux-kernel@vger.kernel.org>,
	<linux-pci@atrey.karlin.mff.cuni.cz>, <netdev@vger.kernel.org>,
	"Jeff Garzik" <jgarzik@pobox.com>, "Andrew Morton" <akpm@osdl.org>
To: "Linas Vepstas" <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:2379 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629AbXCPT7U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 15:59:20 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070316194941.GP5151@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Ideally s2io_reset should
> > return a failure in this case (return is void now)
> 
> Would you care to provide a patch that did this? I could
> experiment a bit, and try to do this myself; but I really
> don't know this hardware, or this driver, that well.
[Ram] Yes, I can submit a patch to address this.

Ram
> 
> --linas
> 

