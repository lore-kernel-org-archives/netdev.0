From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sat, 26 Jan 2008 14:16:01 +0900
Message-ID: <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com>
References: <bug-9816-10286@http.bugzilla.kernel.org/>
	 <20080125142603.a73fd7a2.akpm@linux-foundation.org>
	 <479A6CBD.4010908@gmail.com>
	 <20080125192026.e667f396.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, schwab@suse.de
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:42667 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbYAZFQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 00:16:02 -0500
Received: by rv-out-0910.google.com with SMTP id k20so997587rvb.1
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 21:16:01 -0800 (PST)
In-Reply-To: <20080125192026.e667f396.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/1/26, Andrew Morton <akpm@linux-foundation.org>:
>
> But whatever.   It used to work.  People's scripts will break.  Regression.
>

Also I thought that 'replace with itself' should be error as like Jarek.
But it used to work and patch made a regression, it's my bad :(

I think Julian's recent patches on the list would work for this
replacement issue and regression.

Thanks,
Joonwoo
