From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Wed, 16 May 2007 18:55:04 -0400
Message-ID: <1179356104.4084.23.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
	 <1178911773.4126.26.camel@localhost> <1178972280.4061.7.camel@localhost>
	 <4645F325.3060607@trash.net>  <1178999773.15622.44.camel@localhost>
	 <1179066518.15622.60.camel@localhost> <1179149418.15622.79.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:1463 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757153AbXEPWzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 18:55:11 -0400
Received: by wx-out-0506.google.com with SMTP id h31so355506wxd
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 15:55:09 -0700 (PDT)
In-Reply-To: <1179149418.15622.79.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-14-05 at 09:30 -0400, jamal wrote:
> Incoporating last comments from Patrick.
> Dave, I think this is ready to apply - against net-2.6 from this
> morning. 

Dave - hold onto this patch - Sridhar Samudrala <sri@us.ibm.com> caught
a bug i need to fix (GSO wont work).
The game starting in a few holds priority for now. I will send a patch
either tonight or tommorow morning.
Otoh, if you have applied it - it is a simple incremental patch.

cheers,
jamal


