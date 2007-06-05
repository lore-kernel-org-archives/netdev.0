From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: What test suite exists for SCTP
Date: Tue, 05 Jun 2007 16:38:32 -0400
Message-ID: <4665C9C8.6070504@hp.com>
References: <4665C85C.5030803@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Net Dev <netdev@vger.kernel.org>
To: Paolo Galtieri <pgaltieri@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:59915 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756434AbXFEUig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 16:38:36 -0400
In-Reply-To: <4665C85C.5030803@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paolo Galtieri wrote:
> Vlad,
>  what test suite exists for SCTP?  The lksctp-tools code hasn't been
> updated since Feb of 2006, and I was wondering whether this version is
> still the most useful.
> 
> Thanks

Hi Paolo

I have a lksctp-tools tree on git.kernel.org that's up to date.  We'll need
to release new tools when 2.6.22 ships.

What kind of test suite are you looking for?  There is also a conformance test
suite at http://sctp.fh-muenster.de/sctp-testtool.html, but I haven't played
with it yet.

I also have some home-grown tools that I really need to find time to clean-up and
publish.

-vlad
