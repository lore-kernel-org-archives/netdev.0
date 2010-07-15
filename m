From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCHv3 NEXT 0/5]qlcnic: aer state
Date: Thu, 15 Jul 2010 00:24:48 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F85BA492E@MNEXMB2.qlogic.org>
References: <1279089215-23231-1-git-send-email-amit.salecha@qlogic.com>
 <20100714.103147.193705183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:13535 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387Ab0GOFYw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 01:24:52 -0400
In-Reply-To: <20100714.103147.193705183.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, July 14, 2010 11:02 PM
To: Amit Salecha
Cc: netdev@vger.kernel.org; Ameen Rahman
Subject: Re: [PATCHv3 NEXT 0/5]qlcnic: aer state

From: amit.salecha@qlogic.com
Date: Tue, 13 Jul 2010 23:33:30 -0700

>   I was in under impression that using space after tab is illegal.

What's undesirable is using spaces instead of tabs for fresh
code-block lines like:

	foo();

Also, it is undesirable to have spaces mixed into the middle of a
sequence of tab characters.  The spaces, when used to align expression
continuation lines or lists of function arguments, should be at the
end.

So in cases like:

	if (foo &&
	    bar)

The second line should be a tab character, then the spaces to make
the alignment happen.
