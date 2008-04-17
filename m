From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Thu, 17 Apr 2008 16:59:11 -0400
Message-ID: <1208465951.15888.33.camel@localhost>
References: <20080417103858.0075236b@extreme>
	 <1208464539.15888.22.camel@localhost>  <20080417134656.761748d4@extreme>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:3615 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077AbYDQU7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 16:59:16 -0400
Received: by an-out-0708.google.com with SMTP id d31so57852and.103
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 13:59:15 -0700 (PDT)
In-Reply-To: <20080417134656.761748d4@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-17-04 at 13:46 -0700, Stephen Hemminger wrote:

> The raw flag already existed and humans are the main users.

My scripts dont count as humans ;->
"raw" was not intepreted for the output on u32. Your patch changed the
semantics when you added what amounts to a cooked mode. 
I think changing old standing outputs should be treated in the same
spirit as existing ABIs. Was this ever posted somewhere - I apologize if
the discussion already happened.

cheers,
jamal

