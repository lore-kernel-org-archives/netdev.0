From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Make TCP work better with re-ordered frames?
Date: Wed, 18 May 2016 09:02:46 -0700
Message-ID: <1463587366.18194.130.camel@edumazet-glaptop3.roam.corp.google.com>
References: <573C758E.9050008@candelatech.com>
	 <1463581760.18194.114.camel@edumazet-glaptop3.roam.corp.google.com>
	 <573C8547.3020709@candelatech.com>
	 <1463585133.18194.119.camel@edumazet-glaptop3.roam.corp.google.com>
	 <573C8E42.8090102@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36844 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbcERQCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:02:48 -0400
Received: by mail-pa0-f48.google.com with SMTP id bt5so19107505pac.3
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:02:47 -0700 (PDT)
In-Reply-To: <573C8E42.8090102@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 08:46 -0700, Ben Greear wrote:

> I will work on captures...do you care if it is from transmitter or receiver's perspective?

Receiver would probably be more useful.
