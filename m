From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Thu, 11 Feb 2016 13:20:58 +0100
Message-ID: <20160211132058.303acad9@griffin>
References: <8d2a6ece65b17ae61343dce27f3709d3cd249832.1455118911.git.pabeni@redhat.com>
	<20160211114124.17ae429a@griffin>
	<1455190731.4855.50.camel@redhat.com>
	<20160211131652.0b7066cb@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753174AbcBKMVC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 07:21:02 -0500
In-Reply-To: <20160211131652.0b7066cb@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Feb 2016 13:16:52 +0100, Jiri Benc wrote:
> I don't see a better way out of this now. Fortunately, this does not
> affect route based tunneling.
> 
> Acked-by: Jiri Benc <jbenc@redhat.com>

Oh, and this should go to net, not net-next.

 Jiri

-- 
Jiri Benc
