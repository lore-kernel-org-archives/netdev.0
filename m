From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1] e1000e: Allow ethtool to enable/disable loopback.
Date: Thu, 12 May 2011 00:45:30 -0400 (EDT)
Message-ID: <20110512.004530.900658147557502080.davem@davemloft.net>
References: <1305140625-25888-1-git-send-email-maheshb@google.com>
	<BANLkTikXbL2arWSYW1aPV02C8dDdHTUG6Q@mail.gmail.com>
	<BANLkTimfF4EJ_B=Y-ssjkzmtG123P+HMTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, jeffrey.t.kirsher@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	therbert@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630Ab1ELEpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 00:45:44 -0400
In-Reply-To: <BANLkTimfF4EJ_B=Y-ssjkzmtG123P+HMTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 11 May 2011 16:11:21 -0700

> On Wed, May 11, 2011 at 12:15 PM, Micha=A9=A9 Miros=A9=A9aw <mirqus@g=
mail.com> wrote:
>> 2011/5/11 Mahesh Bandewar <maheshb@google.com>:
>>> This patch adds e1000_set_features() to handle loopback mode. When =
loopback
>>> is enabled, it enables internal-MAC loopback.
>>
>> Please wait for this driver's conversion to hw_features. One comment
>> below, though.
>>
> This is not intrusive so should not create problems when that happens=
=2E

Right and the Intel maintainer folks can resolve such conflicts
anyways.
