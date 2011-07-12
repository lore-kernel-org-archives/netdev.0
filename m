From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] slip: fix wrong SLIP6 ifdef-endif placing
Date: Mon, 11 Jul 2011 20:28:13 -0700 (PDT)
Message-ID: <20110711.202813.544418404281624949.davem@davemloft.net>
References: <CAKh5nabf9OBG7yb5r=v0bhJLjNJgVrw-hVx9quJ9cwcOXSva=Q@mail.gmail.com>
	<20110710.113741.2147626275846755476.davem@davemloft.net>
	<CAKh5nabjFq9RF-CQ_fZd1DG1Ptk7CCtmbknp7Kq6f6HvHmrnxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107Ab1GLD2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 23:28:16 -0400
In-Reply-To: <CAKh5nabjFq9RF-CQ_fZd1DG1Ptk7CCtmbknp7Kq6f6HvHmrnxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Sun, 10 Jul 2011 22:49:26 +0400

> SLIP6 have nothing to do with CSLIP so placing a block of
> SLIP6-related code within a CSLIP ifdef-endif block is incorrect.
> 
> Signed-off-by: Ilya Matvejchikov <matvejchikov@gmail.com>

Applied.
