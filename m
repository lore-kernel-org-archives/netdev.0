From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/fddi:change HWM_REVERSE() macro
Date: Mon, 10 Aug 2015 09:36:29 -0700
Message-ID: <1439224589.2322.109.camel@perches.com>
References: <6AE77A24-5AC5-47E4-8B9F-9BCDE0C6A8F9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, open list <linux-kernel@vger.kernel.org>
To: yalin wang <yalin.wang2010@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0109.hostedemail.com ([216.40.44.109]:50706 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751602AbbHJQgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 12:36:32 -0400
In-Reply-To: <6AE77A24-5AC5-47E4-8B9F-9BCDE0C6A8F9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-11 at 00:14 +0800, yalin wang wrote:
> HWM_REVERSE

Is unused and it would be better if removed.
