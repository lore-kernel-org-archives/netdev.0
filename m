From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: optimize bind(0) if many ports are in use
Date: Mon, 26 Jan 2009 21:35:48 -0800 (PST)
Message-ID: <20090126.213548.154288439.davem@davemloft.net>
References: <4979ADCA.2080106@cosmosbay.com>
	<4979C9B6.3080302@cosmosbay.com>
	<497D724F.3070902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: v.mayatskih@gmail.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39264
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751170AbZA0Ffu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:35:50 -0500
In-Reply-To: <497D724F.3070902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 26 Jan 2009 09:20:31 +0100

> [PATCH] udp: optimize bind(0) if many ports are in use

Applied, thanks a lot everyone.
