From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing,
 take 2
Date: Mon, 25 Jun 2007 19:15:39 -0400
Message-ID: <46804C9B.5060102@garzik.org>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com> <a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com> <20070625153450.c5f535ca.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pradeep singh <pradeep.rautela@gmail.com>, trivial@kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54978 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbXFYXPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 19:15:42 -0400
In-Reply-To: <20070625153450.c5f535ca.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> (Who maintains this driver now?)


It was abandonware from the beginning of its life.  Stephen H and 
Francois R did a bunch of cleanups most recently.

	Jeff


