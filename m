From: "David Laight" <David.Laight@ACULAB.COM>
Subject: copyright in net/usb/ax188179_178a.c
Date: Tue, 10 Sep 2013 12:16:47 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7323@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39106 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751326Ab3IJLRt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 07:17:49 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27021-01 for <netdev@vger.kernel.org>;
 Tue, 10 Sep 2013 12:17:47 +0100 (BST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The copyright at the top of net/usb/ax188179_178a.c just says
   Copyright (C) 2011-2113 ASIX
However a lot of the code comes from the earlier driver
so the earlier copyrights should have been copied over.
(Unless it can be determined that all the changes related
to one of the copyrights have not been carried forwards.)

	David
