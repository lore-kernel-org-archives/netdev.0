From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 0/3] ptp: feature enhancements
Date: Wed, 28 Sep 2011 10:00:24 +0200
Message-ID: <20110928080023.GB6670@netboy.at.omicron.at>
References: <cover.1316518332.git.richard.cochran@omicron.at>
 <20110926.160443.1205173553442138535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39163 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab1I1IAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 04:00:35 -0400
Received: by fxe4 with SMTP id 4so302115fxe.19
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 01:00:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110926.160443.1205173553442138535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2011 at 04:04:43PM -0400, David Miller wrote:
> Could you please add a test at the point where we pull in the
> ->tx_type value from the user, to make sure it is one of the
> validly defined HWTSTAMP_TX_FOO values?

Okay, will do. Any chance of getting the bug fixes in for 3.1?

Thanks,
Richard
