From: jamal <hadi@cyberus.ca>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 17:43:26 -0400
Message-ID: <1190411007.4231.54.camel@localhost>
References: <1190359905.3551.28.camel@magi.nadr>
	 <1190375946.4261.42.camel@localhost>  <1190379015.3551.57.camel@magi.nadr>
	 <1190381841.4231.10.camel@localhost> <1190382366.4231.13.camel@localhost>
	 <46F3E695.7010604@candelatech.com> <1190409160.4231.29.camel@localhost>
	 <46F435CD.1090502@intel.com> <1190410187.4231.43.camel@localhost>
	 <46F438F3.5030201@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Emil Micek <emil.micek@tkrjasek.cz>,
	netdev mailing list <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:43368 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754801AbXIUVnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 17:43:32 -0400
Received: by an-out-0708.google.com with SMTP id d31so152581and
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 14:43:30 -0700 (PDT)
In-Reply-To: <46F438F3.5030201@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 14:34 -0700, Kok, Auke wrote:

> I never saw any bugreports about e1000 not being able to accept vlan packets
> because of this, so I'm quite certain it works OK, feel free to find me a case
> where this isn't so :)

If you tell me it can be done on the rx, i will take your word for it;->
Emil can certainly verify it. 
The tx you certainly have issues - Look at one of the suggestions from
Chris, i think it is resolvable.

cheers,
jamal

