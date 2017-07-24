From: David Miller via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH net 0/2] bpf: fix verifier min/max
	handling in BPF_SUB
Date: Mon, 24 Jul 2017 14:03:38 -0700 (PDT)
Message-ID: <20170724.140338.1602510670649992676.davem@davemloft.net>
References: <2ebcb201-2f18-7276-f4f9-f2bbaffae179@solarflare.com>
Reply-To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ast-b10kYP2dOMg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <2ebcb201-2f18-7276-f4f9-f2bbaffae179-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Date: Fri, 21 Jul 2017 14:35:17 +0100

> I managed to come up with a test for the swapped bounds in BPF_SUB, so here
>  it is along with a patch that fixes it, separated out from my 'rewrite
>  everything' series so it can go to -stable.

Series applied and queued up for -stable, thanks.
