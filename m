From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Question about vlans, bonding, etc.
Date: Thu, 13 May 2010 18:12:18 -0700
Message-ID: <20100513181218.021aa771@nehalam>
References: <i2tb65cae941005031706o19a6f1e9zc86b33d73462113f@mail.gmail.com>
	<1272948506.2407.174.camel@edumazet-laptop>
	<AANLkTikVJqN6m5nsJsFSNHS_HbOFyt0hGr_8MHu6tWDR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: "George B." <georgeb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50186 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313Ab0ENBMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 21:12:20 -0400
In-Reply-To: <AANLkTikVJqN6m5nsJsFSNHS_HbOFyt0hGr_8MHu6tWDR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 May 2010 18:10:33 -0700
"George B." <georgeb@gmail.com> wrote:

> vlan5 on the second interface, vconfig balks that it already exists.

vconfig is stupid. use 'ip link'


-- 
