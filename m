From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of
 timestamps?
Date: Tue, 04 Mar 2014 13:56:08 -0800
Message-ID: <53164BF8.7010403@hp.com>
References: <53151E55.9000503@hp.com> <CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com> <53162093.1040208@hp.com> <CABrhC0k5-x=qJgH4izXtRR=9+cLJh_emAy9Yt=+xrY6K5982Fg@mail.gmail.com> <53162A6E.2010907@hp.com> <CADVnQyn7qqAZn5ZF8wQP_Hn-9s84uc4DUC6r8_ne7bY5Kexycg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Heffner <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:30479 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245AbaCDV4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:56:09 -0500
In-Reply-To: <CADVnQyn7qqAZn5ZF8wQP_Hn-9s84uc4DUC6r8_ne7bY5Kexycg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2014 12:35 PM, Neal Cardwell wrote:
> What's the receiver OS in this trace?

It is my understanding that the receiver has a FreeBSD-based stack.

rick
