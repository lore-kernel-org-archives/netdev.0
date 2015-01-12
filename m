From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net] alx: fix alx_poll()
Date: Mon, 12 Jan 2015 09:55:42 +0100
Message-ID: <1421052942.1891.7.camel@sipsolutions.net>
References: <54B18DFF.80400@amd.com>
	 <1420923485.5947.85.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54B199EB.1080004@amd.com>
	 <1420926614.5947.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421001138.5947.100.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oded Gabbay <oded.gabbay@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	"Bridgman, John" <John.Bridgman@amd.com>,
	"Elifaz, Dana" <Dana.Elifaz@amd.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35050 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbbALIzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 03:55:48 -0500
In-Reply-To: <1421001138.5947.100.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-11 at 18:32 +0000, Eric Dumazet wrote:

> Commit d75b1ade567f ("net: less interrupt masking in NAPI") uncovered
> wrong alx_poll() behavior.

[...]

Thanks Eric and Oded! :)

johannes
