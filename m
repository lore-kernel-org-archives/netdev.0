From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Tue, 20 Mar 2007 09:26:29 -0700
Message-ID: <46000B35.9070800@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net>	<45FB005D.9060809@goop.org>	<1174127638.8897.75.camel@localhost.localdomain>	<20070318.003309.71088169.davem@davemloft.net>	<20070318120814.GA45869@muc.de>	<1174272469.11680.23.camel@localhost.localdomain>	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>	<1174348905.11680.54.camel@localhost.localdomain>	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Zachary Amsden <zach@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@muc.de>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:55237 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbXCTQ0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 12:26:31 -0400
In-Reply-To: <m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Looking at the above code snippet.  I guess it is about time to
> merge our per_cpu and pda variables...

Rusty has a nice patch series to do just that; I think he's still
looking for a taker.

    J
