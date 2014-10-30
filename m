From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] reduce verifier memory consumption and
 add tests
Date: Thu, 30 Oct 2014 15:45:15 -0400 (EDT)
Message-ID: <20141030.154515.250654452794791308.davem@davemloft.net>
References: <1414534303-9906-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, edumazet@google.com,
	dborkman@redhat.com, luto@amacapital.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414534303-9906-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 28 Oct 2014 15:11:40 -0700

> Small set of cleanups:
>  - reduce verifier memory consumption
>  - add verifier test to check register state propagation and state equivalence
>  - add JIT test reduced from recent nmap triggered crash

Series applied, thanks.
