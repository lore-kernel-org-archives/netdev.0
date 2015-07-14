From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]r8169: Serialise some operations from open
 close
Date: Tue, 14 Jul 2015 14:29:21 -0700 (PDT)
Message-ID: <20150714.142921.309696508310966246.davem@davemloft.net>
References: <20150714202311.GA5189@192-168-0-3.rdsnet.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533AbbGNV3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 17:29:24 -0400
In-Reply-To: <20150714202311.GA5189@192-168-0-3.rdsnet.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please do not post patches as attachments.

Instead, inline them as unmolested ASCII text in the main message
body along with your commit message.

>From Documentation/email-clients.txt:

====================
General Preferences
----------------------------------------------------------------------
Patches for the Linux kernel are submitted via email, preferably as
inline text in the body of the email.  Some maintainers accept
attachments, but then the attachments should have content-type
"text/plain".  However, attachments are generally frowned upon because
it makes quoting portions of the patch more difficult in the patch
review process.
====================
