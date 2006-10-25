From: Michael Buesch <mb@bu3sch.de>
Subject: Re: about 802.11i IBSS support
Date: Wed, 25 Oct 2006 15:05:10 +0200
Message-ID: <200610251505.11087.mb@bu3sch.de>
References: <1161766481.8668.38.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, Jiri Benc <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:17048
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965192AbWJYNGM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 09:06:12 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1161766481.8668.38.camel@devlinux-hong>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 25 October 2006 10:54, Hong Liu wrote:
> 2. wpa_supplicant: this is the big part, we need to implement the authenticator
>    in it. Not sure how much efforts needed?

Well, I think that should go together with a merge of wpa_supplicant
with hostapd (which I think is desired anyway).

-- 
Greetings Michael.
