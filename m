From: Brent Casavant <bcasavan@sgi.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Tue, 8 Jan 2008 18:08:33 -0600 (CST)
Message-ID: <alpine.BSF.1.00.0801081808120.24286@pkunk.americas.sgi.com>
References: <alpine.BSF.1.00.0801081556580.24286@pkunk.americas.sgi.com>  <4783FBD6.1000004@hp.com>  <7b9198260801081453s198af7efycc7c35668c65eaf1@mail.gmail.com>  <alpine.BSF.1.00.0801081716010.24286@pkunk.americas.sgi.com>  <7b9198260801081539x7aee72fbm53b5f298c5faf56@mail.gmail.com>
 <7b9198260801081546u50f11e9ck32ec6f071efa300d@mail.gmail.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Tom Spink <tspink@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:36740 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751916AbYAIAIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 19:08:35 -0500
In-Reply-To: <7b9198260801081546u50f11e9ck32ec6f071efa300d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jan 2008, Tom Spink wrote:

> Ach.  I *am* missing something... and what I'm missing is my
> understanding of the sendmsg and recvmsg calls.

No problem.  We all have those days. :)

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
