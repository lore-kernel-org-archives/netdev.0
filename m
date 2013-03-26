From: Serge Hallyn <serge.hallyn@ubuntu.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Tue, 26 Mar 2013 09:33:21 -0500
Message-ID: <20130326143321.GA21768@sergelap>
References: <CD773D0D.7614%blourdel@juniper.net>
 <87wqsu72r6.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benoit Lourdelet <blourdel@juniper.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:53107 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759803Ab3CZOd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 10:33:28 -0400
Content-Disposition: inline
In-Reply-To: <87wqsu72r6.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually, lxc is using random names now, so it's ok.

Benoit, can you use the patches from Eric with lxc (or use the script
you were using before but specify names as he said)?

-serge
