From: Arvid Brodin <arvid.brodin@enea.com>
Subject: header_ops and virtual devices
Date: Wed, 23 Nov 2011 20:26:44 +0100
Message-ID: <4ECD48F4.40501@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:20732 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753323Ab1KWT0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 14:26:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Which device's header_ops->create() is called when several devices are
involved in the egress path of a frame? For example, with VLAN configured?
I'm having a hard time following the code...

-- 
Arvid Brodin
Enea Services Stockholm AB
