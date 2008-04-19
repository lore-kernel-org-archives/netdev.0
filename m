From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Fri, 18 Apr 2008 20:08:16 -0400
Message-ID: <1208563696.4450.43.camel@localhost>
References: <20080417103858.0075236b@extreme>
	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>
	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>
	 <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost>
	 <4808AEBF.7040504@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:54155 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbYDSAIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 20:08:21 -0400
Received: by an-out-0708.google.com with SMTP id d31so206082and.103
        for <netdev@vger.kernel.org>; Fri, 18 Apr 2008 17:08:20 -0700 (PDT)
In-Reply-To: <4808AEBF.7040504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-18-04 at 16:22 +0200, Patrick McHardy wrote:

> 
> Yes, that sucks (ran into the same problem with iproute in a
> previous job). I added the ENV dump format to libnl a couple
> of years ago (NAME=val), should be easy to add a set of simple
> tools to get the information and export it in the environment.

Can you explain this a little? Would these variables define what
the command line parameters look like before invoking?

cheers,
jamal

