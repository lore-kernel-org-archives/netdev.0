From: Patrick McHardy <kaber@trash.net>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 07 Oct 2008 13:31:22 +0200
Message-ID: <48EB488A.40409@trash.net>
References: <20081006202401.14f03be2@speedy> <48EA9096.8010505@trash.net> <48EACA2A.1030005@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42363 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbYJGLb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 07:31:29 -0400
In-Reply-To: <48EACA2A.1030005@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Patrick McHardy wrote:
>> Actually I don't maintain vconfig and I don't think Ben does either.
>> Its deprecated and iproute is what people should use, all the new
>> features are not supported by vconfig.
 >>
> I can fix these things if anyone cares, but leaving it crufty might be a 
> better way to encourage folks to use 'ip'.

I think it would make sense to add a note to the manpage
or something like that. Maybe also a runtime warning in
case its really (going to be) unmaintained.
