From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8678] New: Kernel OOPSes when suspend/resume
Date: Tue, 26 Jun 2007 14:25:46 -0700
Message-ID: <20070626142546.dd529a93.akpm@linux-foundation.org>
References: <bug-8678-10286@http.bugzilla.kernel.org/>
	<200706261942.14722.cijoml@volny.cz>
	<200706262159.05917.rjw@sisk.pl>
	<200706262316.15007.cijoml@volny.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: CIJOML <cijoml@volny.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52429 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757371AbXFZV0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 17:26:30 -0400
In-Reply-To: <200706262316.15007.cijoml@volny.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Jun 2007 23:16:14 +0200
CIJOML <cijoml@volny.cz> wrote:

> > Can you please retest without DRM?
> >
> > Greetings,
> > Rafael
> 
> Ehm What is DRM??? Digital Right Management????

Direct-rendering manager: the thing which does accelerated 3d
in X.

Disable CONFIG_DRM in your .config.
