From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: txqueuelen has wrong units; should be time
Date: Wed, 2 Mar 2011 17:41:32 +0100 (CET)
Message-ID: <alpine.DEB.1.10.1103021739550.7942@uplift.swm.pp.se>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com> <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se> <1298793252.8726.45.camel@edumazet-laptop> <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org> <AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com> <cbb9e1113901f1a324359b6ed3f1a611@localhost> <AANLkTikje6rvjSfEA3CvUjdgFwzk-SBZDdO5kQvi6LZy@mail.gmail.com> <AANLkTin_jY_J7tJseMLVmrQVVRezOVQTGCgB_6tefgXJ@mail.gmail.com>
 <alpine.DEB.1.10.1103010137400.7942@uplift.swm.pp.se> <20110301222531.24832a93@nehalam> <alpine.DEB.1.10.1103020736260.7942@uplift.swm.pp.se> <20110301230754.5ef4ab35@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: John Heffner <johnwheffner@gmail.com>,
	Bill Sommerfeld <wsommerfeld@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Albert Cahalan <acahalan@gmail.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:42862 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754924Ab1CBQld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 11:41:33 -0500
In-Reply-To: <20110301230754.5ef4ab35@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Mar 2011, Stephen Hemminger wrote:

> Also WRED is not default on faster links because it can't be done fast 
> enough.

Before this propagates as some kind of truth. Cisco modern core routers 
have no problems doing WRED at wirespeed, the above statement is not true.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
