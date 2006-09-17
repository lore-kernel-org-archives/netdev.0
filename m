From: Roland Dreier <roland@digitalvampire.org>
Subject: Re: [PATCH 1/3][ATM]: [he] he_init_one() is declared __devinit, but
 calls __init functions
Date: Sun, 17 Sep 2006 14:54:47 -0700
Message-ID: <87y7si40rc.fsf@digitalvampire.org>
References: <200609170018.k8H0IPxV025280@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sccrmhc14.comcast.net ([204.127.200.84]:45209 "EHLO
	sccrmhc14.comcast.net") by vger.kernel.org with ESMTP
	id S965130AbWIQVyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Sep 2006 17:54:52 -0400
To: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
In-Reply-To: <200609170018.k8H0IPxV025280@cmf.nrl.navy.mil> (chas williams's
 message of "Sat, 16 Sep 2006 20:18:25 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sat, 16 Sep 2006 15:44:55 -0400

Not really a big deal -- but in general it's probably better to try
and preserve authorship information.

All you need is to add a

From: Roland Dreier <roland@digitalvampire.org>

line at the beginning of the body of the patch.

Thanks,
  Roland
