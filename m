From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 16:42:39 -0700
Message-ID: <448F4D6F.9070601@candelatech.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <20060613140716.6af45bec@localhost.localdomain> <20060613052215.B27858@openss7.org> <448F2A49.5020809@google.com> <20060613154031.A6276@openss7.org> <Pine.LNX.4.64.0606131655580.4856@turbotaz.ourhouse>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brian F. G. Bidulock" <bidulock@openss7.org>,
	Daniel Phillips <phillips@google.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:34728 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932231AbWFMXnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 19:43:18 -0400
To: Chase Venters <chase.venters@clientec.com>
In-Reply-To: <Pine.LNX.4.64.0606131655580.4856@turbotaz.ourhouse>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chase Venters wrote:

> At least some of us feel like stable module APIs should be explicitly 
> discouraged, because we don't want to offer comfort for code that 
> refuses to live in the tree (since getting said code into the tree is 
> often a goal).

Some of us write modules for specific features that are not wanted in
the mainline kernel, even though they are pure GPL.  Our life is hard
enough with out people setting out to deliberately make things more
difficult!

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

