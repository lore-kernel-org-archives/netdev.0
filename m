From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 23 Apr 2008 10:46:28 -0700
Message-ID: <480F75F4.3010408@hp.com>
References: <480E8523.4030007@hp.com>	<1e41a3230804221917m4af32ed9ice8225c943d3ffa2@mail.gmail.com>	<20080422.205945.229828014.davem@davemloft.net>	<480F64B2.7060608@hp.com>	<1e41a3230804230958s4d7bb997pee2c7cbdd8448391@mail.gmail.com>	<480F70C9.7010004@hp.com> <1e41a3230804231041x6fc7cba7pd73447201faf555d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:36833 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbYDWRqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:46:31 -0400
In-Reply-To: <1e41a3230804231041x6fc7cba7pd73447201faf555d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Autotuning's job is mainly just to grow the buffer sizes to as much
> as congestion control needs to do its thing.

It seems very, well, trusting in that regard.

rick jones
