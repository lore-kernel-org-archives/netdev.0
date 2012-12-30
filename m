From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: implement carrier change
Date: Sun, 30 Dec 2012 02:32:43 -0800 (PST)
Message-ID: <20121230.023243.1327921483859016813.davem@davemloft.net>
References: <1356831061-1483-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083Ab2L3Kco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 05:32:44 -0500
In-Reply-To: <1356831061-1483-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Sat, 29 Dec 2012 23:31:01 -0200

> The user space teamd daemon may need to control the
> master's carrier state depending on the selected mode.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied.
