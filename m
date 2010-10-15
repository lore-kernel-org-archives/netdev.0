From: jamal <hadi@cyberus.ca>
Subject: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch datapath
Date: Fri, 15 Oct 2010 07:31:32 -0400
Message-ID: <1287142292.3642.19.camel@bigi>
References: <20100830062755.GA22396@verge.net.au>
	 <87k4n8ow1r.fsf@benpfaff.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Pfaff <blp@nicira.com>, Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58660 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198Ab0JOLbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 07:31:35 -0400
Received: by gyg13 with SMTP id 13so13372gyg.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 04:31:34 -0700 (PDT)
In-Reply-To: <87k4n8ow1r.fsf@benpfaff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, slightly off topic - and this old (catching up 
with netdev randomly going backwards)..

I was curious after seeing the exchange with Eric D. on
the tunnels and how you have your own tree so i glossed 
over what your project is doing.

It seems to me that you reinvented things that exist in 
Linux already such as bridging, tunnels and what really
caught my attention: ability to do flows (tc actions).
It is possible Linux is missing something you wanted or was
not efficient enough? 
[For example: I couldnt see anything you needed
on flow-action management that Linux couldnt do already
(with already very nice well structured netlink APIs)]

cheers,
jamal

