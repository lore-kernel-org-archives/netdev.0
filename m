From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: add tcpi_segs_in and tcpi_segs_out to tcp_info
Date: Wed, 20 May 2015 17:48:09 -0700
Message-ID: <555D2B49.30702@hp.com>
References: <1430260098-14127-1-git-send-email-edumazet@google.com> <20150512130855.GA29412@localhost.localdomain> <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com> <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com> <555D218D.50509@hp.com> <1432168631.4060.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Craig Gallek <cgallek@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:55817 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbbEUAsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 20:48:14 -0400
In-Reply-To: <1432168631.4060.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2015 05:37 PM, Eric Dumazet wrote:

> Anyway, if we can send tcp data at 100Gbits on one flow, I guess we are
> doing a terrific job and do not need to tweak TCP stack anymore ;)

:)

rick
