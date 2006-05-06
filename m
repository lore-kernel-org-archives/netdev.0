From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC] Proposed structure for Regulatory/Geographical Wireless
 database
Date: Sat, 06 May 2006 14:24:29 -0500
Message-ID: <445CF7ED.9080705@lwfinger.net>
References: <445BB22B.30505@lwfinger.net> <200605062048.46390.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:24536 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750781AbWEFTYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 15:24:38 -0400
To: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Faidon Liambotis <faidon@cube.gr>,
	Rick Jones <rick.jones2@hp.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Harald Welte <laforge@gnumonks.org>,
	Jouni Malinen <jkm@devicescape.com>,
	Christoph Hellwig <hch@infradead.org>
In-Reply-To: <200605062048.46390.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Friday 05 May 2006 22:14, you wrote:
>> # Groups follow countries
>> #
>> Group 0         - Unspecified Country
>> #
>> # Band  Ch. Range       Ch. Spacing     Power   Flags
>           ^^^^^^^^^
> Aren't there countries around, where there are gaps in the
> allowed channel numbers? (Especially for 802.11a) So it would
> not be an allowed "range", but an allowed list of channels.
> 

Yes, but the gaps are only in 802.11a that I know about. If there is a gap, then I use a second line 
as was shown in the example for the standard EU specs. In most cases, other factors change as well. 
I initially was going to specify the allowed channels, but the tables got very long. This way is 
more compact.

Larry

