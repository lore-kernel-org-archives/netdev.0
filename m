From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/7] Network namespace manipulation with file descriptors
Date: Mon, 09 May 2011 12:59:55 -0700
Message-ID: <m1oc3btzk4.fsf@fess.ebiederm.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<20110509.120408.48494155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	hadi@cyberus.ca, daniel.lezcano@free.fr, containers@lists.osdl.org,
	renatowestphal@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110509.120408.48494155.davem@davemloft.net> (David Miller's
	message of "Mon, 09 May 2011 12:04:08 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> The networking bits look OK to me:
>
> Acked-by: David S. Miller <davem@davemloft.net>

Are you merging sendmmsg through the netdev tree?

The conflicts on syscall syscall numbers are an unfortunate pain.

Eric
