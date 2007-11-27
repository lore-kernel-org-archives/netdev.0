From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 07:46:04 +0100
Message-ID: <20071127064604.GA1735@ff.dom.local>
References: <474B47CA.1050802@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Pommnitz <pommnitz@yahoo.com>, netdev@vger.kernel.org,
	OLSR discussion and development <olsr-users@olsr.org>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:50994 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751053AbXK0Gl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 01:41:29 -0500
Content-Disposition: inline
In-Reply-To: <474B47CA.1050802@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26-11-2007 23:25, Jarek Poplawski wrote:
...
> Are you doing this on the same box? I was tracing this long time ago too, and, if
> I didn't miss something, it was about the place! So, as I recall (after finding
> some old message) this TOS is considered only for packets going through the FORWARD
> chain. (But, I haven't checked this at all now, so "no complaints"...)

...Too exactly! Iptables aren't needed for this, so "going through
the forward." should be enough...

Jarek P.
