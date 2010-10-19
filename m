From: David Vrabel <david.vrabel@csr.com>
Subject: Future of the Wimedia LLC Protocol (WLP) subsystem/drivers
Date: Tue, 19 Oct 2010 17:30:47 +0100
Message-ID: <4CBDC7B7.5070108@csr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cluster-g.mailcontrol.com ([208.87.233.190]:46732 "EHLO
	cluster-g.mailcontrol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab0JSQa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 12:30:58 -0400
Received: from cameurexb01.EUROPE.ROOT.PRI ([193.128.72.68])
	by rly16g.srv.mailcontrol.com (MailControl) with ESMTP id o9JGUrUu001347
	for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 17:30:56 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've have been nominally the maintainer of the Wimedia LLC Protocol
(WLP) subsystem and driver since it was originally submitted.  I am no
longer in a position to even pretend to be a maintainer.

The only usable hardware was an Intel i1480 devices with beta firmware
that was never released as a product.  Intel have since sold all there
UWB/WLP IP and I see little prospect of there ever being hardware
commercially available for WLP.

Here are a number of options:

1. Someone else maintains it.  Any volunteers?

2. It gets labelled as Orphaned in MAINTAINERS.

3. It gets moved to staging.

4, It gets removed.

If no one says anything I'll submit a patch to Linus to mark it as Orphaned.

David
-- 
David Vrabel, Senior Software Engineer, Drivers
CSR, Churchill House, Cambridge Business Park,  Tel: +44 (0)1223 692562
Cowley Road, Cambridge, CB4 0WZ                 http://www.csr.com/


Member of the CSR plc group of companies. CSR plc registered in England and Wales, registered number 4187346, registered office Churchill House, Cambridge Business Park, Cowley Road, Cambridge, CB4 0WZ, United Kingdom
