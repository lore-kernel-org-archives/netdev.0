From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] codel: add forgotten inline to functions in header file
Date: Thu, 11 Feb 2016 07:12:35 -0800
Message-ID: <1455203555.19473.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1455199701-25767-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1455201038.19473.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32EA0E6FD@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36547 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbcBKPMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 10:12:36 -0500
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32EA0E6FD@hasmsx107.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-11 at 15:05 +0000, Grumbach, Emmanuel wrote:


> Yeah :) codel_should_drop seemed very long indeed... I wanted to use the
> codel_get_time and associated utils (_before, _after) in iwlwifi.
> They're better than jiffies... So maybe I can just copy that code to
> iwlwifi.


You certainly can submit a patch adding the inline, but not on all
functions present in this file ;)

Thanks !
