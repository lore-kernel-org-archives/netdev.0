From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Re: Bad network performance over 2Gbps
Date: Mon, 21 Apr 2008 09:58:15 -0700
Message-ID: <480CC7A7.4070709@intel.com>
References: <1208282804.23631.27.camel@localhost> <175f5a0f0804151315x1e192fc7p7dac1e84fd154211@mail.gmail.com> <48051173.5030802@intel.com> <48051734.1000107@redhat.com> <1208426550.6049.10.camel@localhost> <48078AF6.2020003@intel.com> <20080421152821.GA18452@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Anton Titov <a.titov@host.bg>, Chris Snook <csnook@redhat.com>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10613 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784AbYDUQ7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 12:59:41 -0400
In-Reply-To: <20080421152821.GA18452@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> 
>> We keep seing this exact issue pop up everywhere - especially with 
>> e1000(e) datacenter users - this code _has_ to go or be fixed. Since 
>> there is a perfectly viable solution, I strongly suggest disabling it.
> 
> strongly agreed. Thanks Auke, applied.
> 
> 	Ingo


excellent, ignore my other reply to Pavel - I didn't see this reply yet :)

Thanks Ingo


Auke

