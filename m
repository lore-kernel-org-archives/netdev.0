From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 18:18:01 -0600
Message-ID: <20060613181801.A8460@openss7.org>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <Pine.LNX.4.64.0606131655580.4856@turbotaz.ourhouse> <448F4D6F.9070601@candelatech.com> <200606131906.16683.chase.venters@clientec.com>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	Daniel Phillips <phillips@google.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:49074 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S932327AbWFNASD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 20:18:03 -0400
To: Chase Venters <chase.venters@clientec.com>
Content-Disposition: inline
In-Reply-To: <200606131906.16683.chase.venters@clientec.com>; from chase.venters@clientec.com on Tue, Jun 13, 2006 at 07:05:54PM -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chase,

On Tue, 13 Jun 2006, Chase Venters wrote:
> I'm trying to imagine what kind of legitimate non-GPL modules might 
> use them.

Example: in-kernel RTP implementation derived from AT&T rtp-lib
implementation (non-GPL compatible license) utilizing this kernel
interface for UDP socket access.
