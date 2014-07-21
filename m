From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: AF_PACKET: tx_ring mirrored in rx_ring?
Date: Mon, 21 Jul 2014 17:13:12 +0200
Message-ID: <53CD2E08.7070204@redhat.com>
References: <53CD1326.5090006@ng4t.com> <53CD1AE5.10408@redhat.com> <53CD2661.8070707@ng4t.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Mihail Dakov <mihail.dakov@ng4t.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932489AbaGUPNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 11:13:19 -0400
In-Reply-To: <53CD2661.8070707@ng4t.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2014 04:40 PM, Mihail Dakov wrote:
...
> What'd you mean by local traffic? The packets which are replicated are destined to remote machine(s).

Sure, but you are sending them out via your packet socket.
