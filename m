From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: hard_start_xmit struct sk_buff read-only?
Date: Sat, 22 Dec 2007 07:32:41 +0100 (CET)
Message-ID: <249190.1925.qm@web52006.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52006.mail.re2.yahoo.com ([206.190.49.253]:40693 "HELO
	web52006.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751059AbXLVGjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 01:39:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An old article about Linux's network drivers mentioned
that the struct sk_buff whose pointer is passed to a
driver's hard_start_xmit function is read-only to the
function. Is that still so? If it is, there is no
mention about it in the kernel tree as far as I know.


      Heute schon einen Blick in die Zukunft von E-Mails wagen? www.yahoo.de/mail
