From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 1/2] rt2x00: fix breakage after pkt_type field was removed
Date: Wed, 13 Dec 2006 18:00:13 +0100
Message-ID: <200612131800.13590.IvDoorn@gmail.com>
References: <20061213170036.E313D3AA7EF@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:19781 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965014AbWLMRAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:00:25 -0500
Received: by nf-out-0910.google.com with SMTP id o25so572401nfa
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 09:00:23 -0800 (PST)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061213170036.E313D3AA7EF@silver.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 December 2006 18:00, Jiri Benc wrote:
> Fix breakage after pkt_type field was removed from ieee80211_tx_control.

Hmm, I must have missed that patch.
Your patch looks good to me.
Thanks

> Signed-off-by: Jiri Benc <jbenc@suse.cz>

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com
