From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add initrwnd to iproute2
Date: Sat, 26 Dec 2009 11:08:55 -0800
Message-ID: <20091226110855.6f43bcb4@nehalam>
References: <pvm8wd3alec.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, chavey@google.com,
	eric.dumazet@gmail.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58193 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbZLZTJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 14:09:27 -0500
In-Reply-To: <pvm8wd3alec.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Dec 2009 15:05:15 -0800
chavey@google.com wrote:

> Add initrwnd option parsing to iproute. This option uses the new
> rtnetlink init_rcvwnd to set the TCP initial receive window size
> advertised by passive and active TCP connections.

Holding off iproute2 change until kernel change is accepted
and merged

-- 
