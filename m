From: David Howells <dhowells@redhat.com>
Subject: Re: [guv v2 04/31] net: Replace __get_cpu_var uses
Date: Mon, 02 Sep 2013 22:35:06 +0100
Message-ID: <7435.1378157706@warthog.procyon.org.uk>
References: <00000140bc5ef9df-d7f75909-a25e-4471-84b2-dfbec07117b0-000000@email.amazonses.com> <20130826204351.725357339@linux.com>
Cc: dhowells@redhat.com, Tejun Heo <tj@kernel.org>,
	akpm@linuxfoundation.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org,
	Steven Rostedt <srostedt@redhat.com>,
	linux-kernel@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <00000140bc5ef9df-d7f75909-a25e-4471-84b2-dfbec07117b0-000000@email.amazonses.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Would it be possible to use __thread annotations for per-CPU variables, I
wonder?

David
