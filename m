From: "Bonitch, Joseph" <Joseph.Bonitch@xerox.com>
Subject: RE: IPV6 stateless autoconfig: prefix route lifetime issue
Date: Fri, 9 May 2008 10:03:47 -0400
Message-ID: <BECE1C148A85274EB554378A3E0EDF4906335F5D@USA0300MS02.na.xerox.net>
References: <BECE1C148A85274EB554378A3E0EDF4906335DEE@USA0300MS02.na.xerox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wvmler2.mail.xerox.com ([13.8.138.217]:35611 "EHLO
	wvmler2.mail.xerox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbYEIOEZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 10:04:25 -0400
Received: from wvmlir2.mail.xerox.com (wvmlir2.mail.xerox.com [13.147.8.222])
	by wvmler2.mail.xerox.com (8.14.2/8.13.8) with ESMTP id m49E4Oik019900
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 07:04:24 -0700
Received: from wvmlir2.mail.xerox.com (localhost [127.0.0.1])
	by wvmlir2.mail.xerox.com (8.13.8/8.13.6) with ESMTP id m49E4Lca016542
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 07:04:21 -0700
Received: from USA7061GW002.na.xerox.net (usa7061gw002.na.xerox.net [13.151.210.15])
	by wvmlir2.mail.xerox.com (8.13.8/8.13.6) with ESMTP id m49E4KiR016477
	for <netdev@vger.kernel.org>; Fri, 9 May 2008 07:04:21 -0700
Content-class: urn:content-classes:message
In-Reply-To: <BECE1C148A85274EB554378A3E0EDF4906335DEE@USA0300MS02.na.xerox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In my original note:
> valid lifetime >= 0x7fffffff * HZ
Should have been
 Valid lifetime * HZ >= 0x7fffffff

Joe

