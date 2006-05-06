From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC] Proposed structure for Regulatory/Geographical Wireless database
Date: Sat, 6 May 2006 20:48:46 +0200
Message-ID: <200605062048.46390.mb@bu3sch.de>
References: <445BB22B.30505@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Faidon Liambotis <faidon@cube.gr>,
	Rick Jones <rick.jones2@hp.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Harald Welte <laforge@gnumonks.org>,
	Jouni Malinen <jkm@devicescape.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:33447
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751084AbWEFSly
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 14:41:54 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <445BB22B.30505@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 05 May 2006 22:14, you wrote:
> # Groups follow countries
> #
> Group 0         - Unspecified Country
> #
> # Band  Ch. Range       Ch. Spacing     Power   Flags
          ^^^^^^^^^
Aren't there countries around, where there are gaps in the
allowed channel numbers? (Especially for 802.11a) So it would
not be an allowed "range", but an allowed list of channels.

-- 
Greetings Michael.
