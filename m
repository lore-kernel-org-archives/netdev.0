From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Mon, 14 Nov 2011 10:40:52 -0800
Message-ID: <4EC160B4.2040709@hp.com>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	fbl@redhat.com, benjamin.poirier@gmail.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:16553 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275Ab1KNSlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 13:41:00 -0500
In-Reply-To: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2011 12:16 AM, Jiri Pirko wrote:
> This patch introduces new network device called team. It supposes to be
> very fast, simple, userspace-driven alternative to existing bonding
> driver.

What is the definition of "very" here - relative to bonding I presume? 
Are there actual performance figures available at this point?  Something 
along the lines of test through both on the same hardware.  I don't have 
HW on which to run myself but would be quite happy to help with say 
netperf command selection to demonstrate the difference between the two.

happy benchmrking,

rick jones
