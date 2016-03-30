From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/5] wireless: ti: Convert specialized logging macros to
 kernel style
Date: Wed, 30 Mar 2016 14:36:31 -0700
Message-ID: <1459373791.25110.132.camel@perches.com>
References: <cover.1457395071.git.joe@perches.com>
	 <87shz85gkq.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0149.hostedemail.com ([216.40.44.149]:47035 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751653AbcC3Vgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 17:36:35 -0400
In-Reply-To: <87shz85gkq.fsf@purkki.adurom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-30 at 14:51 +0300, Kalle Valo wrote:
> Joe Perches <joe@perches.com> writes:
> > Using the normal kernel logging mechanisms makes this code
> > a bit more like other wireless drivers.
> Personally I don't see the point but I don't have any strong opinions. A
> bigger problem is that TI drivers are not really in active development
> and that's I'm not thrilled to take big patches like this for dormant
> drivers.

Not very dormant.

35 patches in the last year, most of them adding functionality.
