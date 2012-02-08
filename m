From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 00/50] set addr_assign_type to NET_ADDR_RANDOM if
 a random mac address get assigned to a netdevice
Date: Wed, 08 Feb 2012 18:29:42 -0500 (EST)
Message-ID: <20120208.182942.1223790992368933837.davem@davemloft.net>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dkukawka@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


50 patches is way too many patches to submit and expect people
to review at one time.

You must do one of two things:

1) Condense the series down to a smaller number of more managable
   patches.  Perhaps combine all the completely trivial conversion
   cases into one single patch, and post the non-trivial cases
   seperately.

2) Only submit a few of these changes at a time, not all at once.

It's your choice, but what you did here is unacceptable.
