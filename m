From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCHv4] fragment locally generated tunnel-mode IPSec6 packets as
 needed
Date: Sun, 19 Dec 2010 08:07:06 -0800
Message-ID: <OFB6CDFBC7.E3781712-ON882577FE.0058793D-882577FE.00588A13@us.ibm.com>
References: <1292622162.1700.3.camel@IBM-1B506CFC885>	<20101218021606.GA26888@gondor.apana.org.au> <20101218.143423.189688024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:44753 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab0LSQHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 11:07:15 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBJG1JWF010895
	for <netdev@vger.kernel.org>; Sun, 19 Dec 2010 09:01:19 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBJG78Oc167236
	for <netdev@vger.kernel.org>; Sun, 19 Dec 2010 09:07:08 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBJG77l1031933
	for <netdev@vger.kernel.org>; Sun, 19 Dec 2010 09:07:08 -0700
In-Reply-To: <20101218.143423.189688024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 12/18/2010 02:34:23 PM:

> So is the TAHI test regression caused by v3 fixed here in v4?

Yes.

                +-DLS

