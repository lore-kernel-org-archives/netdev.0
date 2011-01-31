From: Bill Sommerfeld <wsommerfeld@google.com>
Subject: Re: [PATCH] Make INET_LHTABLE_SIZE a compile-time tunable
Date: Mon, 31 Jan 2011 13:52:03 -0800
Message-ID: <AANLkTi=5ncH6aRY5ifA0TONB7L5RDdHkriMY1p=aDxs6@mail.gmail.com>
References: <1295041688-16550-1-git-send-email-wsommerfeld@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:11916 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756565Ab1AaVxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 16:53:30 -0500
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p0VLrTIv032709
	for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 13:53:29 -0800
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by hpaq2.eem.corp.google.com with ESMTP id p0VLphxj007278
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 13:53:28 -0800
Received: by qyl38 with SMTP id 38so3603375qyl.18
        for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 13:53:27 -0800 (PST)
In-Reply-To: <1295041688-16550-1-git-send-email-wsommerfeld@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 13:48, I wrote:
> INET_LHTABLE_SIZE has been fixed at 32 for a long time. =A0It should =
be
> tunable as larger systems may be running many more than 32 listeners.

I haven't seen any responses to this patch submission.  Can someone
take a look?  Thanks.

                    - Bill
