From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: PPPoE performance regression
Date: Wed, 13 Jun 2012 17:32:20 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F47@saturn3.aculab.com>
References: <20120613163108.GE2361@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Nathan Williams" <nathan@traverse.com.au>,
	"Karl Hiramoto" <karl@hiramoto.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Paul Mackerras" <paulus@samba.org>,
	"John Crispin" <blogic@openwrt.org>
To: "Benjamin LaHaise" <bcrl@kvack.org>,
	"David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34854 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751688Ab2FMQd0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 12:33:26 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17525-04 for <netdev@vger.kernel.org>;
 Wed, 13 Jun 2012 17:33:24 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120613163108.GE2361@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> I would contend that PPPoE over br2684 is not the common case.  The
vast 
> majority of users in client mode are going to be using PPPoE over an 
> ethernet link to a DSL modem (or cable or wireless radios even).  Just
look 
> at what DSL modems are available for users in computer stores / what
ISPs 
> actually ship to their users.  Real ATM exposing devices are rare.

PPPoA is common in the UK.

	David
