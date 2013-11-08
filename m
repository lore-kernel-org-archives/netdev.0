From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Fri, 8 Nov 2013 11:07:41 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73F1@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73EF@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "David Laight" <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>,
	"Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55631 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753126Ab3KHLLh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 06:11:37 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31070-03 for <netdev@vger.kernel.org>;
 Fri,  8 Nov 2013 11:11:33 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73EF@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> While this change improves things a lot (it runs for 20 minutes rather than
> a few seconds), there is still something else wrong.

Almost certainly caused by an unrelated local change.

	David
