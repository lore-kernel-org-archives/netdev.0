From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/3] team: couple of fixes
Date: Fri, 24 Aug 2012 20:53:12 +0200
Message-ID: <130981B9-1F44-47BF-9EE1-C7CD3BADD735@resnulli.us>
References: <1345728413-10298-1-git-send-email-jiri@resnulli.us> <20120824.134705.178022240623528140.davem@davemloft.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:62992 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759393Ab2HXSxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 14:53:21 -0400
Received: by wibhr14 with SMTP id hr14so1269782wib.1
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 11:53:19 -0700 (PDT)
In-Reply-To: <20120824.134705.178022240623528140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


24. 8. 2012 v 19:47, David Miller <davem@davemloft.net>:

> From: Jiri Pirko <jiri@resnulli.us>
> Date: Thu, 23 Aug 2012 15:26:50 +0200
> 
>> + vlan helper
>> 
>> Jiri Pirko (3):
>>  teamd: don't print warn message on -ESRCH during event send
>>  vlan: add helper which can be called to se it device is used by vlan
>>  team: do not allow to add VLAN challenged port when vlan is used
> 
> Applied with typos corrected :-)

I owe you a beer :)

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
