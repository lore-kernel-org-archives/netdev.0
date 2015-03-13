From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next 0/2] bpf: allow extended BPF programs access
 skb fields
Date: Fri, 13 Mar 2015 11:40:04 +0100
Message-ID: <5502BE84.7020105@iogearbox.net>
References: <1426213271-8363-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426213271-8363-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/13/2015 03:21 AM, Alexei Starovoitov wrote:
...
> Daniel,
> patch 1 includes a bit of code that does prog_realloc and branch adjustment
> to make room for new instructions. I think you'd need the same for your
> 'constant blinding' work. If indeed that would be the case, we'll make it
> into a helper function.

Yes, thanks will take care of that.

Cheers,
Daniel
