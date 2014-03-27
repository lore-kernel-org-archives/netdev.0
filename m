From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 13:57:11 +0100
Message-ID: <20140327125711.GL2845@minipsycho.orion>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <53334A3F.6020105@mojatatu.com>
 <20140327072107.GC2845@minipsycho.orion>
 <5333FD12.9060404@mojatatu.com>
 <20140327110223.GA1615@casper.infradead.org>
 <533408C0.8000608@mojatatu.com>
 <20140327120012.GA13573@casper.infradead.org>
 <53341A63.3000004@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:64392 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbaC0M5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 08:57:15 -0400
Received: by mail-ee0-f45.google.com with SMTP id d17so2828030eek.18
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 05:57:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53341A63.3000004@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 27, 2014 at 01:32:35PM CET, jhs@mojatatu.com wrote:
>On 03/27/14 08:00, Thomas Graf wrote:
>
>>It seems like we reached pretty good consensus on the model. What
>>remaining issues do you see with the port model proposed in v2?
>>
>
>Are we really following the same thread?
>I dont see any rallying behind Jiri's approach from the
>other folks who have their own code and way of approaching things.
>I am hoping we dont continue with the split that is there
>already.

It is not a split. It is just a completion of a model. Adding missing
parts. At least I see it that way.

>
>cheers,
>jamal
