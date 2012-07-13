From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tipc: Use pr_fmt
Date: Fri, 13 Jul 2012 12:04:33 -0700
Message-ID: <1342206273.626.0.camel@joe2Laptop>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
	 <1342115481.13046.5.camel@joe2Laptop>
	 <20120713154544.GA31280@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49425 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933498Ab2GMTEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 15:04:44 -0400
In-Reply-To: <20120713154544.GA31280@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-13 at 11:45 -0400, Paul Gortmaker wrote:
> [[PATCH net-next] tipc: Use pr_fmt] On 12/07/2012 (Thu 10:51) Joe Perches wrote:
> > How about extending this to use the more common pr_fmt prefix?
> We can probably do that.  I'll incorporate that into the 3/8 patch,
> rather than have two similar patches in the series, with the 2nd just
> going in and touching all the same lines a second time.

Hi Paul, that sounds fine to me,  cheers, Joe
