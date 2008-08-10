From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Sun, 10 Aug 2008 10:03:15 -0400
Message-ID: <82e4877d0808100703x62f42ac8q989ef0722b61c5c9@mail.gmail.com>
References: <bug-11297-10286@http.bugzilla.kernel.org/>
	 <20080809213101.0927a808.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	brian.haley@hp.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:48157 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbYHJODQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 10:03:16 -0400
Received: by wx-out-0506.google.com with SMTP id h29so978474wxd.4
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 07:03:15 -0700 (PDT)
In-Reply-To: <20080809213101.0927a808.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 10, 2008 at 12:31 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:

> Can you please confirm the version numbers here?  2.6.26-rc4 was OK,
> but 2.6.26 and 2.6.27-rc2 are busted?
>

John Gumb's original report (referenced in bugzilla) says the issue is
happening since 2.6.26-rc4 and that 2.6.26.2 also had it.
Current mainline also has this problem (tested on everything past 2.6.27-rc2).

Parag
