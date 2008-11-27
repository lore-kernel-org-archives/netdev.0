From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 12:53:01 -0800
Message-ID: <20081127125301.3cb1e282@linux.intel.com>
References: <492DD792.6080302@linux.intel.com>
	<20081127115236.GE29013@elte.hu>
	<492EE087.80708@linux.intel.com>
	<20081127201836.GA16869@elte.hu>
	<20081127122800.45fc0b1a@linux.intel.com>
	<20081127204714.GA25875@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yinghai@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jesse Barnes <jbarnes@virtuousgeek.org>,
	"H. Peter Anvin" <hpa@zytor.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36850 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbYK0UwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 15:52:05 -0500
In-Reply-To: <20081127204714.GA25875@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Nov 2008 21:47:14 +0100
Ingo Molnar <mingo@elte.hu> wrote:

> IIRC the problem is that vmware _does_ claim that it supports MTRRs. 

it might.
but even if they would fix that, we would still WARN (
at least we should do our side correctly...


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
