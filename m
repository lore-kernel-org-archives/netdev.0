From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: sctp_diag should dump sctp socket type
Date: Wed, 25 May 2016 12:24:21 -0700 (PDT)
Message-ID: <20160525.122421.1141954704190813920.davem@davemloft.net>
References: <53ebf63eb6de080418949f52d0d3556af2a371e1.1464203668.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net, phil@nwl.cc
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbcEYTYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 15:24:24 -0400
In-Reply-To: <53ebf63eb6de080418949f52d0d3556af2a371e1.1464203668.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 26 May 2016 03:14:28 +0800

> For sctp_diag, ss support is not officially available, thus there
> are no official users of this yet, so we can add this field in the
> middle of sctp_info without breaking user API.

This is not what matters.

What matters is if a released kernel went out with the existing API.
