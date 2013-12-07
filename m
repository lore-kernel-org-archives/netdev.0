From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] ipv6 addrconf: extend ifa_flags to u32
Date: Sat, 7 Dec 2013 09:51:47 +0100
Message-ID: <20131207085147.GB2496@minipsycho.orion>
References: <1386319522-2102-1-git-send-email-jiri@resnulli.us>
 <1386319522-2102-2-git-send-email-jiri@resnulli.us>
 <20131206.163518.1817492341433351545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:62207 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036Ab3LGIvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 03:51:51 -0500
Received: by mail-ee0-f45.google.com with SMTP id d49so673750eek.4
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 00:51:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131206.163518.1817492341433351545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 06, 2013 at 10:35:18PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri,  6 Dec 2013 09:45:21 +0100
>
>> There is no more space in u8 ifa_flags. So do what davem suffested and
>> add another netlink attr called IFA_FLAGS for carry more flags.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> Signed-off-by: Thomas Haller <thaller@redhat.com>
>
>Applied, can you extend the handling of this attribute to the other
>protocols as I asked you to?


Will send follow-up. Thanks.
