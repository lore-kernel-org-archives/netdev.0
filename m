From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Thu, 17 Apr 2008 17:24:40 -0400
Message-ID: <1208467480.15888.50.camel@localhost>
References: <20080417103858.0075236b@extreme>
	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>
	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:49171 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbYDQVYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 17:24:44 -0400
Received: by an-out-0708.google.com with SMTP id d31so60093and.103
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 14:24:43 -0700 (PDT)
In-Reply-To: <20080417140837.1e92b449@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-17-04 at 14:08 -0700, Stephen Hemminger wrote:

> By that logic no program output would ever change. 


Ok, come on now Stephen;-> You dont think theres consequences to
changing output for a program that had the same exact output for like 10
years? If you dont believe me, try changing the output of programs like
ifconfig, route etc which people are all the time scripting around and
see how loud they scream. I see this in the same way.

Note: I am not arguing against changing output - it could be done if
there was some discussion which resulted in enough warning. We give i
think a years warning for ABI changes.

cheers,
jamal

