From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net:drivers/net: Miscellaneous conversions to
 ETH_ALEN
Date: Tue, 01 Oct 2013 23:40:54 -0700
Message-ID: <1380696054.2081.35.camel@joe-AO722>
References: <1380679480.2081.24.camel@joe-AO722>
	 <87k3hw469z.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ath10k@lists.infradead.org
To: Kalle Valo <kvalo@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0170.hostedemail.com ([216.40.44.170]:40671 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752490Ab3JBGk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 02:40:58 -0400
In-Reply-To: <87k3hw469z.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 07:59 +0300, Kalle Valo wrote:
> (Cutting the CC smaller)

Please include netdev.  (cc'd)

> Joe Perches <joe@perches.com> writes:
> 
> > Convert the memset/memcpy uses of 6 to ETH_ALEN
> > where appropriate.
[]
> > Signed-off-by: Joe Perches <joe@perches.com>
[]
> Acked-by: Kalle Valo <kvalo@qca.qualcomm.com>
