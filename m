From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 3/4] netfilter: ipv6: in-place replacement of
 last skb
Date: Tue, 20 Oct 2015 22:46:58 +0200
Message-ID: <20151020204657.GJ4386@breakpoint.cc>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
 <1445112865-31523-4-git-send-email-fw@strlen.de>
 <CANr6G5zgPbVeagJUePm9+e_fxSBu5Kr9iYM_k+Eh672h0Pa9kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANr6G5zgPbVeagJUePm9+e_fxSBu5Kr9iYM_k+Eh672h0Pa9kQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Stringer <joestringer@nicira.com> wrote:
> This hunk looks very similar to the logic in ip_frag_reasm(). Did you
> consider refactoring to share it?

Could be done but I did not plan to do that.
