From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 net-next 1/4] net: flow_dissector: avoid multiple
 calls in eBPF
Date: Wed, 04 Jun 2014 23:55:41 -0700 (PDT)
Message-ID: <20140604.235541.751933005917980567.davem@davemloft.net>
References: <CAMEtUuxK5hV_eORRLaSHSiwF5X82Ae91vL6W0-6au48v8H6bAA@mail.gmail.com>
	<CA+ZOOTPdDDeGxZVGXVRZmjkxqkGefgDLrawo_9YXbjwTQ_FLzA@mail.gmail.com>
	<538EDE1A.8060305@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chema@google.com, ast@plumgrid.com, mingo@kernel.org,
	rostedt@goodmis.org, a.p.zijlstra@chello.nl, acme@infradead.org,
	jolsa@redhat.com, tglx@linutronix.de, hpa@zytor.com,
	akpm@linux-foundation.org, keescook@chromium.org,
	edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dborkman@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <538EDE1A.8060305@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


FWIW, I'm not applying this series.

There is no real consensus and a lot more discussion and time is
needed before anything happens here.
