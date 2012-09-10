From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] iproute2: tc.8: update UNITS section.
Date: Mon, 10 Sep 2012 09:35:20 -0700
Message-ID: <20120910093520.16ac508f@nehalam.linuxnetplumber.net>
References: <1346132337-21325-1-git-send-email-lw@cn.fujitsu.com>
	<1346222516-14814-1-git-send-email-lw@cn.fujitsu.com>
	<20120829111956.77d504ce@s6510.linuxnetplumber.net>
	<504D4252.4030104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39735 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971Ab2IJQfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:35:50 -0400
In-Reply-To: <504D4252.4030104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Sep 2012 09:28:50 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> On 08/30/2012 02:19 AM, Stephen Hemminger wrote:
> > On Wed, 29 Aug 2012 14:41:56 +0800
> > Li Wei <lw@cn.fujitsu.com> wrote:
> > 
> >> - rename section UNITS to PARAMETERS.
> >> - break section PARAMETERS down to four subsections to cover the
> >>   common used parameter types(RATES, TIMES, SIZES, VALUES).
> >> - add some explaination for IEC units in RATES.
> >> - point out the max value we can set for RATES, TIMES and SIZES.
> >>
> >> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
> > 
> > Plan to merge this when I get back next week.
> 
> ping ...
> 
> > 
> > 

Pushed it out this morning.
