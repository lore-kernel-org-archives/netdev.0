From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/3] netpoll: store local and remote ip in
 net-endian
Date: Sat, 28 Mar 2009 23:56:30 -0700 (PDT)
Message-ID: <20090328.235630.128546056.davem@davemloft.net>
References: <1238290711.3492.9.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33480
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752422AbZC2G4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 02:56:41 -0400
In-Reply-To: <1238290711.3492.9.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Sat, 28 Mar 2009 18:38:31 -0700

> Allows for the removal of byteswapping in some places and
> the removal of HIPQUAD (replaced by %pI4).
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
