From: David Miller <davem@redhat.com>
Subject: Re: [GIT net] Open vSwitch
Date: Wed, 05 Feb 2014 16:26:10 -0800 (PST)
Message-ID: <20140205.162610.551022240482803520.davem@redhat.com>
References: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55483 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753187AbaBFA0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Feb 2014 19:26:18 -0500
In-Reply-To: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue,  4 Feb 2014 22:59:16 -0800

> A handful of bug fixes for net/3.14. High level fixes are:
>  * Regressions introduced by the zerocopy changes, particularly with
>    old userspaces.
>  * A few bugs lingering from the introduction of megaflows.
>  * Overly zealous error checking that is now being triggered frequently
>    in common cases.

Pulled, thanks Jesse.
