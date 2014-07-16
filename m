From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] SCTP updates
Date: Wed, 16 Jul 2014 14:44:10 -0700 (PDT)
Message-ID: <20140716.144410.2191854657630314423.davem@davemloft.net>
References: <1405189840-31171-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geirola@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbaGPVoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 17:44:11 -0400
In-Reply-To: <1405189840-31171-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat, 12 Jul 2014 20:30:34 +0200

> This set improves the SCTP socket API to be more in line with
> RFC6458, Geir and myself have finalized it eventually. While
> at it, the first patch also fixes two possible information
> leaks that should go to net tree as well. For more details, I
> refer you to the patches themselves.
> 
> v1 -> v2:
>  - Added 6th patch to deprecate SCTP_SNDRCV, rest unchanged

Now that patch #1 has propagated into net-next, I applied the
rest of this series, thanks.
