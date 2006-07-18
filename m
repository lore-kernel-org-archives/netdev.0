From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 0/9] d80211: pull request
Date: Tue, 18 Jul 2006 17:46:43 +0200
Message-ID: <20060718174643.398cabd2@griffin.suse.cz>
References: <20060718174442.485760904.midnight@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42971 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932289AbWGRPqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:46:45 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060718174442.485760904.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jul 2006 17:45:20 +0200 (CEST), Jiri Benc wrote:
> Please pull from
> git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git master
> to obtain following patches:
> 
> Jiri Benc:
>       d80211: do not receive through master interface when not scanning
>       d80211: host_gen_beacon_template flag
>       d80211: better deallocation of mdev
>       d80211: fix receiving through virtual interfaces
>       d80211: fix defragmentation
>       d80211: optimize defragmentation
>       d80211: SET_NETDEV_DEV for non-master devices
> 
> Michael Wu:
>       d80211: Replace rc4 code with crypto api arc4
>       d80211: Add sparse bitwise annotations

Sorry, John, forgot to add you to the To: list.

 Jiri

-- 
Jiri Benc
SUSE Labs
